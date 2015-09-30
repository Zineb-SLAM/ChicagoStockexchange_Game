element(X,[X|_]):-!.
element(X,[_|Q]):- element(X,Q).

element_num(1,[X|_],X):-!.
element_num(R,[_|L],Elem):- Temp is R-1,
                            element_num(Temp,L,Elem).
nb_element([],0).
nb_element([_|Q], N) :- nb_element(Q, Temp), N is Temp+1.

element_num_bis(1,[X|_],X):-!.
element_num_bis(R,[_|L],Elem):- element_num_bis(Temp,L,Elem),
                            R is Temp+1 .

retirer_element(1,[_|Q],Q):-!.
retirer_element(R,[T|Liste],[T|Newliste]):- Temp is R-1,
                                            retirer_element(Temp,Liste, Newliste).

imprime([]).
imprime([T|Liste]):- write( T ),imprime(Liste).

supprime_first([T|Q], Q, T).


retire(1,[_|Q],Q).
retire(N,[T|Q],[T|Res]):- Tmp is N-1, retire(Tmp,Q,Res).

recup_nieme(0, [T|_], T).
recup_nieme(Indice, [_|Q], Element) :- recup_nieme(N, Q, Element), N is Indice-1.

add_element([T|Y],X,NewL) :- NewL = [X,T|Y].





%*******************************  Initialisation: Predicats ***********************
generer_pile(Nouvelle,[],5,_,Real):- Real=Nouvelle, imprime(Real),nl.
generer_pile(Marchandise,[Elem|Y],I,Newmarch,Real):- I<5,
                                            nb_element(Marchandise,Long),
                                            random(1,Long,R),
                                            element_num(R,Marchandise,Elem),
                                            retirer_element(R,Marchandise,Newmarch),
                                            Temp is I+1 ,
                                            generer_pile(Newmarch,Y,Temp,_,Real).
                                            
generer_marchandise([_|[]],[]).
generer_marchandise(Marchandise,[T|Q]):- write('APPEL'),nl, 
                                        generer_pile(Marchandise,T,1,_,Final), 
                                        generer_marchandise(Final,Q), write('Pile'), imprime(T), nl,nl,nl.



generer_marchandise([],_,[]).
generer_marchandise(Marchandise,[T|Q],Newmarch):- generer_pile(Marchandise,T,1,Newmarch), 
                                                generer(Newmarch,Q,Newmarch).

generer_trader(Pos):- random(1,9,Pos).

plateau_depart([bourse,Marchandises,1,[],[]]):-
                                            generer_marchandise(marchandise,Marchandises).

%*******************************  Affichage ***********************
										
imprime_liste([]):-write(' '),nl.
imprime_liste([T|Q]):-write(T), write(' ,'), imprime_liste(Q).

imprime_liste_liste([]):- write(' ').
imprime_liste_liste([T|Q]):- write('Pile'),write(' : '),imprime_liste(T), nl,imprime_liste_liste(Q).

										
affiche_plateau([Bourse,Marchandises,PositionTrader,ReserveJ1,ReserveJ2]):-
                                            write('Bourse:'),nl,imprime(Bourse),nl,nl,
                                            write('Marchandises:'),nl,imprime_marchandises(Marchandises),nl,nl,
                                            write('PositionTrader:'),nl, write(PositionTrader),nl,
                                            write('Reserve_Joueur1:'),nl,imprime(ReserveJ1),nl,
                                            write('Reserve_Joueur2:'),nl,imprime(ReserveJ2),nl,nl.

debut_jeu(Plateau):- plateau_depart(Plateau),affiche_plateau(Plateau).


%*****************************************************  Jeu **************************************************



deplacer_trader(Marchandises,PositionTrader,Deplacement,NewPositon):- Tmp is PositionTrader+Deplacement,
                                                                       nb_element(Marchandises,Nb), 
                                                                       Tmp>=Nb,NewPositon is Tmp-Nb.


deplacer_trader(_,PositionTrader,Deplacement,Tmp):- Tmp is PositionTrader+Deplacement.
                                                                       

positions_autour_trader(Marchandises,Nb,Pos1,1):- nb_element(Marchandises,Nb), Pos1 is Nb-1,!.
positions_autour_trader(Marchandises,1,Pos1,2):- nb_element(Marchandises,Nb), Pos1 is Nb,!.
positions_autour_trader(_,PositionTrader,Pos1,Pos2):- Pos1 is PositionTrader-1, Pos2 is PositionTrader+1.

marchandise_valide(Marchandises,Gardee,Jetee,Pos1,Pos2):- 
                                            nth(Pos1,Marchandises,Pile_pos1), nth0(0,Pile_pos1,Gardee),
                                            nth(Pos2,Marchandises,Pile_pos2), nth0(0,Pile_pos2,Jetee).

marchandise_valide(Marchandises,Gardee,Jetee,Pos1,Pos2):-
                                            nth(Pos1,Marchandises,Pile_pos1), nth0(0,Pile_pos1,Jetee),
                                            nth(Pos2,Marchandises,Pile_pos2), nth0(0,Pile_pos2,Gardee).

garder(1,Gardee,[],[Gardee],_,_).
garder(1,Gardee,R1,NewR1,R2,R2):- add_element(R1,Gardee,NewR1).


garder(2,Gardee,R1,R1,[],[Gardee]).
garder(2,Gardee,R1,R1,R2,NewR2):-add_element(R2,Gardee,NewR2).




vendre(Bourse,Jetee,NewBourse):-valeur_March(Bourse,Jetee,Valeur), 
                                X is Valeur-1,
                                remplace([Jetee|Valeur],[Jetee|X],Bourse,NewBourse).


substitue(_,_,[],[]).
substitue(X,Y,[X|R],[Y|R]).
substitue(X,Y,[Z|R],[Z|R1]) :- X\=Z, substitue(X,Y,R,R1).

remplace(_,_,[],[]).
remplace(X,Y,[X|Q],[Y|Q2]):- remplace(X,Y,Q,Q2).
remplace(X,Y,[W|Z],[W|ZZ]):- remplace(X,Y,Z,ZZ).


update_march(Marchandises,PositionTrader,NewMarchandise,NewPos):-
                                positions_autour_trader(Marchandises,PositionTrader,Pos1,Pos2),

                                element_num(Pos1,Marchandises,Pile1),
                                retirer_element(1,Pile1,NewPile1),
                                substitue(Pile1,NewPile1,Marchandises,Tmp),

                                element_num(Pos2,Marchandises,Pile2),
                                retirer_element(1,Pile2,NewPile2),
                                substitue(Pile2,NewPile2,Tmp,NewMtemp),
								ajourner_march(NewMtemp,PositionTrader,NewMarchandise,NewPos). 

count([],_,0).
count(X,[X|Q],N) :- count(X,Q,N1),N is N1+1 .
count(X,[Y|Q],N) :- X\==Y,count(X,Q,N).

ajourner_march(M,Pos,M,Pos):- \+element([],M). 
ajourner_march(M,Pos,NewM,NewPos):-element_num_bis(Indice,M,[]),Indice<Pos,NewPostemp is Pos-1,retire(Indice,M,NewMtemp),ajourner_march(NewMtemp,NewPostemp,NewM,NewPos).
ajourner_march(M,Pos,NewM,NewPos):-element_num_bis(Indice,M,[]),Indice>Pos,retire(Indice,M,NewMtemp),ajourner_march(NewMtemp,Pos,NewM,NewPos).
            
                                            


%******************************************************* Jouer un Coup **************************************************


coup_possible([_,Marchandises,PositionTrader,_,_],[Joueur,Deplacement,Gardee,Jetee]):-
                                                        element(Joueur,[1,2]),
                                                        element(Deplacement,[1,2,3]),
                                                        deplacer_trader(Marchandises,PositionTrader,Deplacement,NewPositon),
                                                        positions_autour_trader(Marchandises,NewPositon,Pos1,Pos2),
                                                        marchandise_valide(Marchandises,Gardee,Jetee,Pos1,Pos2).

jouer_coup([B,M,Pos,R1,R2],[J,Deplacement,Gardee,Jetee],[NewB,NewM,NewPos,NewR1,NewR2]):-
                                                    coup_possible([B,M,Pos,R1,R2],[J,Deplacement,Gardee,Jetee]),
                                                    garder(J,Gardee,R1,NewR1,R2,NewR2),
                                                    vendre(B,Jetee,NewB),
                                                    deplacer_trader(M,Pos,Deplacement,NewPostemp),
                                                    update_march(M,NewPostemp,NewM,NewPos).

                                                


%***************************************** Fin du jeu: Score de chaque Joueur et Gagnant ************************


valeur_March([[Jetee|Valeur]|_],Jetee,Valeur):-!.
valeur_March([_|Q],Jetee,Valeur):- valeur_March(Q,Jetee,Valeur).

score_joueur(_,[],0).
score_joueur(Bourse,[X|Y],N):-
                    valeur_March(Bourse,X,Valeur), 
                    score_joueur(Bourse,Y,N1),
                    N is N1+Valeur.

                    


%*************************************************  Menu *************************************

appel(1):-write('Vous avez choisi le mode multijoueur'),nl,start_HH,!.
appel(2):- write('Vous avez choisi de jouer contre Ordinateur'),nl,start_HM,!.
appel(3):-write('Vous avez choisi le jeu automatique'),nl,start_MVSM,!.
appel(4):-write('Au revoir!'),nl,!.
appel(_):-write('Vous avez mal choisi'),nl.

menu:-  write('1.Choix : Mode Joueur1 Vs Joueur2'), nl,
        write('2.Choix 2: Mode Joueur1 Vs Ordinateur'), nl,
        write('3. Choix 3: Mode Ordinateur Vs Ordinateur'), nl,
        write('4. Quitter'),nl,
        write('Entrer un Choix SVP --->'),
        read(Choix),nl, appel(Choix),
        Choix is 4,nl.

			
%*************************************************  INTELLIGENCE ARTIFICIELLE *************************************             

coups_possibles([Bourse,Marchandises,PositionTrader,R1,R2],Joueur,X,Y,Z):-
findall([Joueur,1,Gardee1,Jetee1],coup_possible([Bourse,Marchandises,PositionTrader,R1,R2],[Joueur,1,Gardee1,Jetee1]),X),
findall([Joueur,2,Gardee2,Jetee2],coup_possible([Bourse,Marchandises,PositionTrader,R1,R2],[Joueur,2,Gardee2,Jetee2]),Y),
findall([Joueur,3,Gardee3,Jetee3],coup_possible([Bourse,Marchandises,PositionTrader,R1,R2],[Joueur,3,Gardee3,Jetee3]),Z).

simulation_jouer([1,_,Gardee,Jetee],[Bourse,_,_,R1,R2],Pertinence):- 
												score_joueur(Bourse,R1,N1),
												score_joueur(Bourse,R2,N2),
												garder(1,Gardee,R1,NewR1,R2,R2),
                                                vendre(Bourse,Jetee,NewB),
												score_joueur(NewB,NewR1,NewN1),
												score_joueur(NewB,NewR2,NewN2),
												Mongain is NewN1-N1,
												Saperte is N2-NewN2,
												Pertinence is Mongain+Saperte.

simulation_jouer([2,_,Gardee,Jetee],[Bourse,_,_,R1,R2],Pertinence):- 
												score_joueur(Bourse,R1,N1),
												score_joueur(Bourse,R2,N2),
												garder(2,Gardee,R1,R1,R2,NewR2),
                                                vendre(Bourse,Jetee,NewB),
												score_joueur(NewB,NewR1,NewN1),
												score_joueur(NewB,NewR2,NewN2),
												Mongain is NewN2-N2,
												Saperte is N1-NewN1,
												Pertinence is Mongain+Saperte.
												
elem_max([A,B,C,D,E,F],X):- X is A,X>=A,X>=B,X>=C,X>=D,X>=E,X>=F.
elem_max([A,B,C,D,E,F],X):- X is B,X>=A,X>=B,X>=C,X>=D,X>=E,X>=F.
elem_max([A,B,C,D,E,F],X):- X is C,X>=A,X>=B,X>=C,X>=D,X>=E,X>=F.
elem_max([A,B,C,D,E,F],X):- X is D,X>=A,X>=B,X>=C,X>=D,X>=E,X>=F.
elem_max([A,B,C,D,E,F],X):- X is E,X>=A,X>=B,X>=C,X>=D,X>=E,X>=F.
elem_max([A,B,C,D,E,F],X):- X is F,X>=A,X>=B,X>=C,X>=D,X>=E,X>=F.


meilleur_coup([Bourse,Marchandises,PositionTrader,R1,R2],1,Sol,Coupafaire):-
               coups_possibles([Bourse,Marchandises,PositionTrader,R1,R2],1,[X1,X2],[Y1,Y2],[Z1,Z2]),
               simulation_jouer(X1,[Bourse,Marchandises,PositionTrader,R1,R2],PX1),
			   simulation_jouer(X2,[Bourse,Marchandises,PositionTrader,R1,R2],PX2),
			   simulation_jouer(Y1,[Bourse,Marchandises,PositionTrader,R1,R2],PY1),      
               simulation_jouer(Y2,[Bourse,Marchandises,PositionTrader,R1,R2],PY2),      
               simulation_jouer(Z1,[Bourse,Marchandises,PositionTrader,R1,R2],PZ1),      
               simulation_jouer(Z2,[Bourse,Marchandises,PositionTrader,R1,R2],PZ2),
			   elem_max([PX1,PX2,PY1,PY2,PZ1,PZ2],Sol),
			   element_num_bis(Place,[PX1,PX2,PY1,PY2,PZ1,PZ2],Sol),
			   element_num(Place,[X1,X2,Y1,Y2,Z1,Z2],Coupafaire).

meilleur_coup([Bourse,Marchandises,PositionTrader,R1,R2],2,Sol,Coupafaire):-
               coups_possibles([Bourse,Marchandises,PositionTrader,R1,R2],2,[X1,X2],[Y1,Y2],[Z1,Z2]),
               simulation_jouer(X1,[Bourse,Marchandises,PositionTrader,R1,R2],PX1),
			   simulation_jouer(X2,[Bourse,Marchandises,PositionTrader,R1,R2],PX2),
			   simulation_jouer(Y1,[Bourse,Marchandises,PositionTrader,R1,R2],PY1),      
               simulation_jouer(Y2,[Bourse,Marchandises,PositionTrader,R1,R2],PY2),      
               simulation_jouer(Z1,[Bourse,Marchandises,PositionTrader,R1,R2],PZ1),      
               simulation_jouer(Z2,[Bourse,Marchandises,PositionTrader,R1,R2],PZ2),
			   elem_max([PX1,PX2,PY1,PY2,PZ1,PZ2],Sol),
			   element_num_bis(Place,[PX1,PX2,PY1,PY2,PZ1,PZ2],Sol),
			   element_num(Place,[X1,X2,Y1,Y2,Z1,Z2],Coupafaire).
			   

%*************************************************  Jeu H vs H *************************************

jouer_HH([B,[L1,L2],_,R1,R2],_):- total_score_HH([B,[L1|L2],_,R1,R2],_,_),!.


jouer_HH([B,M,Pos,R1,R2],1):- nl,nl,write('********** Nouveau Tour: ************ '),nl,
                                 nl,write('Le Trader est a  '),write(Pos),nl,
								 write('cest le tour du joueur'),write(1),nl,
                                write('* Bourse : '),imprime_liste(B),nl,
                                write('* Marchandises : '),nl,imprime_liste_liste(M),nl, 
                                write('* De combien voulez vous vous deplacer?  --> '),read(Deplacement1),
                                write('* Que voulez garder? --> '),read(Gardee1),
                                write('* Que voulez vous jeter? --> '),read(Jetee1),
                                jouer_coup([B,M,Pos,R1,R2],[1,Deplacement1,Gardee1,Jetee1],[NewB,NewM,NewPos,NewR1,R2]),
                                write('*Votre Reserve  est de'),imprime_liste(NewR1),nl,
								score_joueur(NewB,NewR1,N1),
								write('*Le Score du joueur 1 est de'),write(N1),nl,nl,
								score_joueur(NewB,R2,N2),
								write('*Le Score du joueur 2 est de'),write(N2),nl,nl,
                                jouer_HH([NewB,NewM,NewPos,NewR1,R2],2),nl,nl.

jouer_HH([B,M,Pos,R1,R2],2):- nl,nl,write('********** Nouveau Tour: ************ '),nl,
                                 nl,write('La place du trader est ---> '),write(Pos),nl,
								 write('cest le tour du joueur'),write(2),nl,
                                write('* Bourse : '),imprime_liste(B),nl,
                                write('* Marchandises : '),nl,imprime_liste_liste(M),nl, 
                                write('* De combien voulez vous vous deplacer?  --> '),read(Deplacement2),
                                write('* Que voulez garder? --> '),read(Gardee2),
                                write('* Que voulez vous jeter? --> '),read(Jetee2),
                                jouer_coup([B,M,Pos,R1,R2],[2,Deplacement2,Gardee2,Jetee2],[NewB,NewM,NewPos,R1,NewR2]),
                                write('*Votre Reserve  est de '),imprime_liste(NewR2),nl,
								score_joueur(NewB,R1,N1),
								write('*Le Score du joueur 1 est de'),write(N1),nl,nl,
								score_joueur(NewB,NewR2,N2),
								write('*Le Score du joueur 2 est de'),write(N2),nl,nl,
                                jouer_HH([NewB,NewM,NewPos,R1,NewR2],1),nl,nl.

start_HH:-  write('Qui commence (Mettez un point a la fin)'),nl,
                                    read(Choix),
									generer_marchandise([ble,ble,ble,ble,ble,ble,ble,riz,riz,riz,riz,riz,riz,
cacao,cacao,cacao,cacao,cacao,cacao,cafe,cafe,cafe,cafe,cafe,cafe,
mais,mais,mais,mais,mais,mais,sucre,sucre,sucre,sucre,sucre,sucre],M),
                                    generer_trader(Pos),
                                    write('Le Jeu Commence'),nl,nl,
                                    jouer_HH([[[ble|7],[riz|6],[cacao|6],[cafe|6],[sucre|6],[mais|6]],M,Pos,[],[]],Choix).

fin_jeu_HH(ScoreJ1,ScoreJ2):- ScoreJ1 > ScoreJ2,!,write('Joueur 1: YOU WIN!'), nl.
fin_jeu_HH(ScoreJ1,ScoreJ2):- ScoreJ1 < ScoreJ2,!,write('Joueur 2: YOU WIN!'), nl.
fin_jeu_HH(ScoreJ1,ScoreJ2):- ScoreJ1 == ScoreJ2,!,write('Il y a egalite'), nl.


total_score_HH([Bourse,_,_,ReserveJ1,ReserveJ2],ScoreJ1,ScoreJ2):-
                                                score_joueur(Bourse, ReserveJ1,ScoreJ1),
                                                score_joueur(Bourse,ReserveJ2,ScoreJ2),
                                                write('------    Score final   ------'), nl,
                                                write('Score du Joueur 1 : '), write(ScoreJ1), nl,
                                                write('Score du Joueur 2 : : '), write(ScoreJ2), nl, nl,
                                                fin_jeu_HH(ScoreJ1,ScoreJ2).
									
									
						
			   
%*************************************************  Jeu M vs H *************************************
jouer_HM([B,[L1,L2],_,R1,R2],_):- total_score_HM([B,[L1|L2],_,R1,R2],_,_),!.

jouer_HM([B,M,Pos,R1,R2],1):- nl,nl,write('********** Nouveau Tour: ************ '),nl,
                                 nl,write('La place du trader est ---> '),write(Pos),nl,
								 write('cest le tour du joueur'),write(1),nl,
                                write('* Bourse : '),imprime_liste(B),nl,nl,
                                write('* Marchandises : '),nl,imprime_liste_liste(M),nl, nl,
                                write('* De combien voulez vous vous deplacer?  --> '),read(Deplacement1),nl,
                                write('* Que voulez garder? --> '),read(Gardee1),nl,
                                write('* Que voulez vous jeter? --> '),read(Jetee1),nl,
                                jouer_coup([B,M,Pos,R1,R2],[1,Deplacement1,Gardee1,Jetee1],[NewB,NewM,NewPos,NewR1,R2]),
                                write('*Votre Reserve  est de'),imprime_liste(NewR1),nl,nl,
								score_joueur(NewB,NewR1,N1),
								write('*Votre score est de'),write(N1),nl,nl,
								score_joueur(NewB,R2,N2),
								write('*Le Score de la machine est de'),write(N2),nl,nl,
                                jouer_HM([NewB,NewM,NewPos,NewR1,R2],2),nl,nl.

jouer_HM([B,M,Pos,R1,R2],2):- nl,nl,write('********** Tour de la Machine ************ '),nl,
                                write('* Bourse : '),imprime_liste(B),nl,
                                write('* Marchandises : '),nl,imprime_liste_liste(M),nl, 
                                write('* La place du trader est ---> '),write(Pos),nl,
                                meilleur_coup([B,M,Pos,R1,R2],2,_,Meilleur),
								write('* La machine effectue le coup :'),nl,
								imprime_liste(Meilleur),nl,nl,
                                jouer_coup([B,M,Pos,R1,R2],Meilleur,[NewB,NewM,NewPos,R1,NewR2]),
                                write('* La reserve de la machine est -->'),imprime_liste(NewR2),nl,nl,
                                score_joueur(NewB,NewR2,N2),
                                write('* Le score de la machine est: '),write(N2),nl,nl,
								score_joueur(NewB,R1,N1),
                                write('* Votre score est maintenant :'),write(N1),nl,nl,
                                jouer_HM([NewB,NewM,NewPos,R1,NewR2],1).

start_HM:- generer_marchandise([ble,ble,ble,ble,ble,ble,ble,riz,riz,riz,riz,riz,riz,
                            cacao,cacao,cacao,cacao,cacao,cacao,cafe,cafe,cafe,cafe,cafe,cafe,
                            mais,mais,mais,mais,mais,mais,sucre,sucre,sucre,sucre,sucre,sucre],M),
                            write(' **********Qui Commence le Jeu ?  **********  '),nl,nl,
                            write(' ********** Entrer "1" pour Vous  **********  '), nl,
                            write(' ********** Entrer "2" pour la Machine  **********  '),nl,nl,
                            read(Choix),nl,              
							generer_trader(Pos),
							write('* La place du trader est -->  '), write(Pos),nl,nl,
                            write('**************May the odds be Ever in your Favour!*****************'),nl, nl,        
                            jouer_HM([[[ble|7],[riz|6],[cacao|6],[cafe|6],[sucre|6],[mais|6]],M,Pos,[],[]],Choix).                    
																	

							
fin_jeu_HM(ScoreJ1,ScoreJ2):- ScoreJ1 > ScoreJ2,!,write('YOU WIN!'), nl.
fin_jeu_HM(ScoreJ1,ScoreJ2):- ScoreJ1 < ScoreJ2,!,write('YOU ARE THE LOSER , TRY AGAIN!'), nl.
fin_jeu_HM(ScoreJ1,ScoreJ2):- ScoreJ1 == ScoreJ2,!,write('Il y a EGALITE... a quand la REVANCHE?'), nl.


total_score_HM([Bourse,_,_,ReserveJ1,ReserveJ2],ScoreJ1,ScoreJ2):-
                                                score_joueur(Bourse, ReserveJ1,ScoreJ1),
                                                score_joueur(Bourse,ReserveJ2,ScoreJ2),
                                                write('------    Score final   ------'), nl,
                                                write('Votre score : '), write(ScoreJ1), nl,
                                                write('Score de la machine : '), write(ScoreJ2), nl, nl,
                                                fin_jeu_HM(ScoreJ1,ScoreJ2).


%*************************************************  Jeu M vs M *************************************   

jouer_MVSM([B,[L1,L2],_,R1,R2],_):- total_score_MVSM([B,[L1|L2],_,R1,R2],_,_),!.


                  
jouer_MVSM([B,M,Pos,R1,R2],1):- nl,nl,write('********** Nouveau Tour: ************ '),nl,
                                 nl,write('La place du trader est ---> '),write(Pos),nl,
								 write('cest le tour de la machine'),write(1),nl,
                                write('* Bourse ---> '),imprime_liste(B),nl,nl,
                                write('* Marchandises ---> '),nl,imprime_liste_liste(M),nl, nl,
								meilleur_coup([B,M,Pos,R1,R2],1,_,Coupafaire),
								write('* La machine effectue le coup :'),nl,
								imprime_liste(Coupafaire),
                                jouer_coup([B,M,Pos,R1,R2],Coupafaire,[NewB,NewM,NewPos,NewR1,R2]),
                                write('*La nouvelle reserve de la machine 1 est de : '),imprime_liste(NewR1),nl,nl,
								score_joueur(NewB,NewR1,N1),
								write('*Son score est de '),write(N1),nl,nl,
								score_joueur(NewB,R2,N2),
								write('*Le Score de la machine 2 est mainenant de'),write(N2),nl,nl,
                                jouer_MVSM([NewB,NewM,NewPos,NewR1,R2],2),nl,nl.

jouer_MVSM([B,M,Pos,R1,R2],2):- nl,nl,write('********** Nouveau Tour: ************ '),nl,
                                write('* Bourse--->'),imprime_liste(B),nl,
                                write('* Marchandises --->'),nl,imprime_liste_liste(M),nl, 
                                write('* La place du trader est ---> '),write(Pos),nl,
                                meilleur_coup([B,M,Pos,R1,R2],2,_,Meilleur),
								write('* La machine effectue le coup :'),nl,
								imprime_liste(Meilleur),nl,nl,
                                jouer_coup([B,M,Pos,R1,R2],Meilleur,[NewB,NewM,NewPos,R1,NewR2]),
                                write('* La reserve de la machine 2 est -->'),imprime_liste(NewR2),nl,nl,
                                score_joueur(NewB,NewR2,N2),
                                write('* Le score de la machine 2 est: '),write(N2),nl,nl,
								score_joueur(NewB,R1,N1),
                                write('* Le score de la machine 1 est maintenant :'),write(N1),nl,nl,
                                jouer_MVSM([NewB,NewM,NewPos,R1,NewR2],1).

start_MVSM:- generer_marchandise([ble,ble,ble,ble,ble,ble,ble,riz,riz,riz,riz,riz,riz,
                            cacao,cacao,cacao,cacao,cacao,cacao,cafe,cafe,cafe,cafe,cafe,cafe,
                            mais,mais,mais,mais,mais,mais,sucre,sucre,sucre,sucre,sucre,sucre],M),
                            write(' **********Mode machine contre machine **********  '),nl,nl,
							generer_trader(Pos),
							write('* La place du trader est -->  '), write(Pos),nl,nl,
                            write('**************May the odds be Ever in your Favour!*****************'),nl, nl,        
                            jouer_MVSM([[[ble|7],[riz|6],[cacao|6],[cafe|6],[sucre|6],[mais|6]],M,Pos,[],[]],1).      
							
	
total_score_MVSM([Bourse,_,_,R1,R2],ScoreJ1,ScoreJ2):-
                                                score_joueur(Bourse, R1,ScoreJ1),
                                                score_joueur(Bourse,R2,ScoreJ2),
                                                write('------    Score final   ------'), nl,
                                                write('Score machine 1 '), write(ScoreJ1), nl,
                                                write('Score machine 2 '), write(ScoreJ2), nl, nl,
                                                fin_jeu_MVSM(ScoreJ1,ScoreJ2).
												
												
fin_jeu_MVSM(ScoreJ1,ScoreJ2):-ScoreJ1 > ScoreJ2,!,write('GAGNANT MACHINE 1'), nl.
fin_jeu_MVSM(ScoreJ1,ScoreJ2):-ScoreJ1 < ScoreJ2,!,write('GAGNANT MACHINE 2'), nl.
fin_jeu_MVSM(ScoreJ1,ScoreJ2):-ScoreJ1 == ScoreJ2,!,write('EGALITE'), nl.