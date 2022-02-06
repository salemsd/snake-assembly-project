################################################################################
#                  Fonctions d'affichage et d'entr?e clavier                   #
################################################################################

# Ces fonctions s'occupent de l'affichage et des entr?es clavier.

.data

# Tampon d'affichage du jeu 256*256 de mani?re lin?aire.

frameBuffer: .word 0 : 1024  # Frame buffer

# Code couleur pour l'affichage
# Codage des couleurs 0xwwxxyyzz o?
#   ww = 00
#   00 <= xx <= ff est la couleur rouge en hexad?cimal
#   00 <= yy <= ff est la couleur verte en hexad?cimal
#   00 <= zz <= ff est la couleur bleue en hexad?cimal

colors: .word 0x00000000, 0x00ff0000, 0xff00ff00, 0x00396239, 0x00ff00ff, 0x00ffd700, 0x0039c6e5, 0x00bd1acf, 0x00ff8200, 0x00fdf690, 0x00132978, 0x008cfbc7, 0x006b2507, 0x00839850, 0x00cd8991, 0x00ebcdf1, 0x00c6f441, 0x00ffffff

#	Couleurs du jeu
.eqv black 0
.eqv red   4
.eqv green 8
.eqv greenV2  12
.eqv rose  16

#	Couleurs du rainbow
.eqv yellow 20
.eqv blue 24
.eqv purple 28
.eqv orange 32
.eqv lightYellow 36
.eqv darkBlue 40
.eqv lightBG 44
.eqv brown 48
.eqv kaki 52
.eqv darkRose 56
.eqv lightRose 60
.eqv lightGreen 64
.eqv white 68




# Derni?re position connue de la queue du serpent.

lastSnakePiece: .word 0, 0





.text
j main

############################# printColorAtPosition #############################
# Param?tres: $a0 La valeur de la couleur
#             $a1 La position en X
#             $a2 La position en Y
# Retour: Aucun
# Effet de bord: Modifie l'affichage du jeu
################################################################################

printColorAtPosition:
lw $t0 tailleGrille
mul $t0 $a1 $t0
add $t0 $t0 $a2
sll $t0 $t0 2
sw $a0 frameBuffer($t0)
jr $ra

################################ resetAffichage ################################
# Param?tres: Aucun
# Retour: Aucun
# Effet de bord: R?initialise tout l'affichage avec la couleur noir
################################################################################

resetAffichage:
lw $t1 tailleGrille
mul $t1 $t1 $t1
sll $t1 $t1 2
la $t0 frameBuffer
addu $t1 $t0 $t1
lw $t3 colors + black

RALoop2: bge $t0 $t1 endRALoop2
  sw $t3 0($t0)
  add $t0 $t0 4
  j RALoop2
endRALoop2:
jr $ra

################################## printSnake ##################################
# Param?tres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage aux emplacement ou se
#                trouve le serpent et sauvegarde la derni?re position connue de
#                la queue du serpent.
################################################################################

printSnake:
subu $sp $sp 12
sw $ra 0($sp)
sw $s0 4($sp)
sw $s1 8($sp)

lw $s0 tailleSnake
sll $s0 $s0 2
li $s1 0
lw $a0 colors + greenV2
lw $a1 snakePosX($s1)
lw $a2 snakePosY($s1)
jal printColorAtPosition
li $s1 4

li $s2 20


PSLoop:
bge $s1 $s0 endPSLoop
  ble $s2 white resetRainbow
  subi $s2, $s2, 52
resetRainbow:   
  lw $a0 colors($s2)
  addi $s2, $s2, 4
  lw $a1 snakePosX($s1)
  lw $a2 snakePosY($s1)
  jal printColorAtPosition
  addu $s1 $s1 4
  j PSLoop
endPSLoop:

subu $s0 $s0 4
lw $t0 snakePosX($s0)
lw $t1 snakePosY($s0)
sw $t0 lastSnakePiece
sw $t1 lastSnakePiece + 4

lw $ra 0($sp)
lw $s0 4($sp)
lw $s1 8($sp)
addu $sp $sp 12
jr $ra

################################ printObstacles ################################
# Param?tres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage aux emplacement des obstacles.
################################################################################

printObstacles:
subu $sp $sp 12
sw $ra 0($sp)
sw $s0 4($sp)
sw $s1 8($sp)

lw $s0 numObstacles
sll $s0 $s0 2
li $s1 0

POLoop:
bge $s1 $s0 endPOLoop
  lw $a0 colors + red
  lw $a1 obstaclesPosX($s1)
  lw $a2 obstaclesPosY($s1)
  jal printColorAtPosition
  addu $s1 $s1 4
  j POLoop
endPOLoop:

lw $ra 0($sp)
lw $s0 4($sp)
lw $s1 8($sp)
addu $sp $sp 12
jr $ra

################################## printCandy ##################################
# Param?tres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage ? l'emplacement du bonbon.
################################################################################

printCandy:
subu $sp $sp 4
sw $ra ($sp)

lw $a0 colors + rose
lw $a1 candy
lw $a2 candy + 4
jal printColorAtPosition

lw $ra ($sp)
addu $sp $sp 4
jr $ra

eraseLastSnakePiece:
subu $sp $sp 4
sw $ra ($sp)

lw $a0 colors + black
lw $a1 lastSnakePiece
lw $a2 lastSnakePiece + 4
jal printColorAtPosition

lw $ra ($sp)
addu $sp $sp 4
jr $ra

################################## printGame ###################################
# Param?tres: Aucun
# Retour: Aucun
# Effet de bord: Effectue l'affichage de la totalit? des ?l?ments du jeu.
################################################################################

printGame:
subu $sp $sp 4
sw $ra 0($sp)

jal eraseLastSnakePiece
jal printSnake
jal printObstacles
jal printCandy

lw $ra 0($sp)
addu $sp $sp 4
jr $ra

############################## getRandomExcluding ##############################
# Param?tres: $a0 Un entier x | 0 <= x < tailleGrille
# Retour: $v0 Un entier y | 0 <= y < tailleGrille, y != x
################################################################################

getRandomExcluding:
move $t0 $a0
lw $a1 tailleGrille
li $v0 42
syscall
beq $t0 $a0 getRandomExcluding
move $v0 $a0
jr $ra

########################### newRandomObjectPosition ############################
# Description: Renvoie une position al?atoire sur un emplacement non utilis?
#              qui ne se trouve pas devant le serpent.
# Param?tres: Aucun
# Retour: $v0 Position X du nouvel objet
#         $v1 Position Y du nouvel objet
################################################################################

newRandomObjectPosition:
subu $sp $sp 4
sw $ra ($sp)

lw $t0 snakeDir
and $t0 0x1
bgtz $t0 horizontalMoving
li $v0 42
lw $a1 tailleGrille
syscall
move $t8 $a0
lw $a0 snakePosY
jal getRandomExcluding
move $t9 $v0
j endROPdir

horizontalMoving:
lw $a0 snakePosX
jal getRandomExcluding
move $t8 $v0
lw $a1 tailleGrille
li $v0 42
syscall
move $t9 $a0
endROPdir:

lw $t0 tailleSnake
sll $t0 $t0 2
la $t0 snakePosX($t0)
la $t1 snakePosX
la $t2 snakePosY
li $t4 0

ROPtestPos:
bge $t1 $t0 endROPtestPos
lw $t3 ($t1)
bne $t3 $t8 ROPtestPos2
lw $t3 ($t2)
beq $t3 $t9 replayROP
ROPtestPos2:
addu $t1 $t1 4
addu $t2 $t2 4
j ROPtestPos
endROPtestPos:

bnez $t4 endROP

lw $t0 numObstacles
sll $t0 $t0 2
la $t0 obstaclesPosX($t0)
la $t1 obstaclesPosX
la $t2 obstaclesPosY
li $t4 1
j ROPtestPos

endROP:
move $v0 $t8
move $v1 $t9
lw $ra ($sp)
addu $sp $sp 4
jr $ra

replayROP:
lw $ra ($sp)
addu $sp $sp 4
j newRandomObjectPosition

################################# getInputVal ##################################
# Param?tres: Aucun
# Retour: $v0 La valeur 0 (haut), 1 (droite), 2 (bas), 3 (gauche), 4 erreur
################################################################################

getInputVal:
lw $t0 0xffff0004
li $t1 115
beq $t0 $t1 GIhaut
li $t1 122
beq $t0 $t1 GIbas
li $t1 113
beq $t0 $t1 GIgauche
li $t1 100
beq $t0 $t1 GIdroite
li $v0 4
j GIend

GIhaut:
li $v0 0
j GIend

GIdroite:
li $v0 1
j GIend

GIbas:
li $v0 2
j GIend

GIgauche:
li $v0 3
j GIend

GIend:
jr $ra

################################ sleepMillisec #################################
# Param?tres: $a0 Le temps en milli-secondes qu'il faut passer dans cette
#             fonction (approximatif)
# Retour: Aucun
################################################################################

sleepMillisec:
move $t0 $a0
li $v0 30
syscall
addu $t0 $t0 $a0

SMloop:
bgt $a0 $t0 endSMloop
li $v0 30
syscall
j SMloop

endSMloop:
jr $ra

##################################### main #####################################
# Description: Boucle principal du jeu
# Param?tres: Aucun
# Retour: Aucun
################################################################################

main:

# Initialisation du jeu

jal resetAffichage
jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4

# Boucle de jeu

mainloop:

jal getInputVal
move $a0 $v0
jal majDirection
jal updateGameStatus
jal conditionFinJeu
bnez $v0 gameOver
jal printGame
lw $t0 vitesse
move $a0 $t0           #500
jal sleepMillisec
j mainloop

gameOver:
jal affichageFinJeu
li $v0 10
syscall

################################################################################
#                                Partie Jeu                                    #
################################################################################

# ? vous de jouer !

.data

tailleGrille:  .word 16        # Nombre de case du jeu dans une dimension.

# La t?te du serpent se trouve ? (snakePosX[0], snakePosY[0]) et la queue ?
# (snakePosX[tailleSnake - 1], snakePosY[tailleSnake - 1])
tailleSnake:   .word 1       # Taille actuelle du serpent.
snakePosX:     .word 0 : 1024  # Coordonn?es X du serpent ordonn? de la t?te ? la queue.
snakePosY:     .word 0 : 1024  # Coordonn?es Y du serpent ordonn? de la t.

# Les directions sont repr?sent?s sous forme d'entier allant de 0 ? 3:
snakeDir:      .word 1         # Direction du serpent: 0 (haut), 1 (droite)
                               #                       2 (bas), 3 (gauche)
numObstacles:  .word 1         # Nombre actuel d'obstacle pr?sent dans le jeu.
obstaclesPosX: .word 2 : 1024  # Coordonn?es X des obstacles
obstaclesPosY: .word 2 : 1024  # Coordonn?es Y des obstacles
candy:         .word 0, 0      # Position du bonbon (X,Y)
scoreJeu:      .word 0         # Score obtenu par le joueur
Message: .asciiz "Votre score est : "
messageABien: .asciiz "Vous pouvez faire mieux !\n"
messageBien: .asciiz "Pas mal il y a du niveau !\n"
messageExcellent: .asciiz "Chapeau, vous etes un as du jeu !\n"
vitesse : 	.word 500
#***-------------------------------------------------------------------------------------------------------------***
#	Dessin de l'affichage fin de jeu

# En vert
drawSnakePosX: .word 8, 8, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15
drawSnakePosY: .word 10, 12, 11, 12, 10, 11, 12, 13, 6, 7, 8, 12, 13, 5, 6, 7, 8, 9, 10, 12, 13, 4, 5, 6, 9, 10, 11, 12, 13, 4, 5, 11, 12, 5, 6
# En jaune clair
drawSnakeEyesPosX: .word 8, 9
drawSnakeEyesPosY: .word 11, 10
# En rouge
drawXPosX: .word 6, 6, 7, 7, 8, 8, 9
drawYPosY: .word 8, 11, 9, 10, 9, 10, 8

# Chiffres	(L = Left, R = Right)
drawZeroLRPosX: .word 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4
drawZeroLPosY: .word 4, 5, 6, 4, 6, 4, 6, 4, 6, 4, 5, 6
drawZeroRPosY: .word 8, 9, 10, 8, 10, 8, 10, 8, 10, 8, 9, 10

drawOneLRPosX: .word 0, 1, 1, 2, 3, 4
drawOneLPosY: .word 6, 5, 6, 6, 6, 6
drawOneRPosY: .word 10, 9, 10, 10, 10, 10

drawTwoLRPosX: .word 0, 0, 0, 1, 2, 2, 2, 3, 4, 4, 4
drawTwoLPosY: .word 4, 5, 6, 6, 5, 6, 4, 4, 4, 5, 6
drawTwoRPosY: .word 8, 9, 10, 10, 9, 10, 8, 8, 8, 9, 10

drawThreeLRPosX: .word 0, 0, 0, 1, 2, 2, 2, 3, 4, 4, 4
drawThreeLPosY: .word 4, 5, 6, 6, 4, 5, 6, 6, 4, 5, 6
drawThreeRPosY: .word 8, 9, 10, 10, 8, 9, 10, 10, 8, 9, 10

drawFourLRPosX: .word 0, 0, 1, 1, 2, 2, 2, 3, 4
drawFourLPosY: .word 4, 6, 4, 6, 4, 5, 6, 6, 6
drawFourRPosY: .word 8, 10, 8, 10, 8, 9, 10, 10, 10

drawFiveLRPosX: .word 0, 0, 0, 1, 2, 2, 2, 3, 4, 4, 4
drawFiveLPosY: .word 4, 5, 6, 4, 4, 5, 6, 6, 4, 5, 6
drawFiveRPosY: .word 8, 9, 10, 8, 8, 9, 10, 10, 8, 9, 10

drawSixLRPosX: .word 0, 0, 0, 1, 2, 2, 2, 3, 3, 4, 4, 4
drawSixLPosY: .word 4, 5, 6, 4, 4, 5, 6, 4, 6, 4, 5, 6
drawSixRPosY: .word 8, 9, 10, 8, 8, 9, 10, 8, 10, 8, 9, 10

drawSevenLRPosX: .word 0, 0, 0, 1, 1, 2, 3, 4
drawSevenLPosY: .word 4, 5, 6, 4, 6, 6, 6, 6
drawSevenRPosY: .word 8, 9, 10, 8, 10, 10, 10, 10

drawEightLRPosX: .word 0, 0, 0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4
drawEightLPosY: .word 4, 5, 6, 4, 6, 4, 5, 6, 4, 6, 4, 5, 6
drawEightRPosY: .word 8, 9, 10, 8, 10, 8, 9, 10, 8, 10, 8, 9, 10

drawNineLRPosX: .word 0, 0, 0, 1, 1, 2, 2, 2, 3, 4, 4, 4
drawNineLPosY: .word 4, 5, 6, 4, 6, 4, 5, 6, 6, 4, 5, 6
drawNineRPosY: .word 8, 9, 10, 8, 10, 8, 9, 10, 10, 8, 9, 10
#***-------------------------------------------------------------------------------------------------------------***

.text

################################# majDirection #################################
# Param?tres: $a0 La nouvelle position demand?e par l'utilisateur. La valeur
#                 ?tant le retour de la fonction getInputVal.
# Retour: Aucun
# Effet de bord: La direction du serpent ? ?t? mise ? jour.
# Post-condition: La valeur du serpent reste intacte si une commande ill?gale
#                 est demand?e, i.e. le serpent ne peut pas faire de demi-tour
#                 en un unique tour de jeu. Cela s'apparente ? du cannibalisme
#                 et ? ?t? proscrit par la loi dans les soci?t?s reptiliennes.
################################################################################

majDirection:


#***-------------------------------------------------------------------------------------------------------------***
lw $s5 snakePosX #pour ne pas écraser les anciennes cordonn?es de la tete !
lw $s6 snakePosY
#***-------------------------------------------------------------------------------------------------------------***
#recuperer le numero associ? a l'ancienne direction
lw $t4 snakeDir
case:	#traiter les differents cas
beq $a0 0 haut		#se diriger vers le haut
beq $a0 1 droit	#se diriger vers la droite
beq $a0 2 bas		#se diriger vers le bas
beq $a0 3 gauche	#se diriger vers la gauche
beq $a0 4 default	#Rester sur l'ancienne direction
#***-------------------------------------------------------------------------------------------------------------***
haut: 
beq $t4 2 default	#pas de cannibalisme
lw $t0 snakePosX($s0)
add $t0 $t0 1
sw $t0 snakePosX($s0)
j fin
#***-------------------------------------------------------------------------------------------------------------***
droit:
beq $t4 3 default	#pas de cannibalisme
lw $t0 snakePosY($s0)
add $t0 $t0 1
sw $t0 snakePosY($s0)
j fin
#***-------------------------------------------------------------------------------------------------------------***
bas :
beq $t4 0 default	#pas de cannibalisme
lw $t0 snakePosX($s0)
sub $t0 $t0 1
sw $t0 snakePosX($s0)
j fin
#***-------------------------------------------------------------------------------------------------------------***
gauche:
beq $t4 1 default	#pas de cannibalisme
lw $t0 snakePosY($s0)
sub $t0 $t0 1
sw $t0 snakePosY($s0)
j fin
#***-------------------------------------------------------------------------------------------------------------***
default:
lw $a0 snakeDir
j case

#***-------------------------------------------------------------------------------------------------------------***
fin:
sw  $a0 snakeDir	# Mettre a jour snakeDir
jr $ra
#***-------------------------------------------------------------------------------------------------------------***

############################### updateGameStatus ###############################
# Param?tres: Aucun
# Retour: Aucun
# Effet de bord: L'?tat du jeu est mis ? jour d'un pas de temps. Il faut donc :
#                  - Faire bouger le serpent
#                  - Tester si le serpent ? manger le bonbon
#                    - Si oui d?placer le bonbon et ajouter un nouvel obstacle
################################################################################

updateGameStatus:

#***-------------------------------------------------------------------------------------------------------------***
sw $ra ($sp)
#***-------------------------------------------------------------------------------------------------------------***
#position X de bonbon
lw $t0 candy
#position de la tete
lw $t1 snakePosX($0)
lw $t2 snakePosY($0)
#comparer au cordonn?es de bonbon
bne $t0 $t1 finu	#jump ves finu si on mange pas le bonbon
#position y de candy
lw $t0 candy + 4
bne  $t0 $t2 finu	#jump vers finu si on mange pas le bonbon 
#sinon on cree un nouveau bonbon avec des cordonn?es aleatoires
#***-------------------------------------------------------------------------------------------------------------***
jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4
lw $t0 tailleSnake
add $t0 $t0 1		#Augmenter la taille de snake 
sw $t0 tailleSnake
#mettre a jour le score
lw $t0 scoreJeu
add $t0 $t0 1
sw $t0 scoreJeu

lw $t1 vitesse
sub $t1 $t1 5
sw $t1 vitesse

#Generer un nouvel obstacle apres qu'on ait mang? le bonbon.
jal newRandomObjectPosition
lw $t3 numObstacles
add $t3 $t3 1
sw $t3 numObstacles 
sub $t3 $t3 1
mul $t3 $t3 4
sw $v0 obstaclesPosX($t3)
sw $v1 obstaclesPosY($t3)
#***-------------------------------------------------------------------------------------------------------------***
finu:
#Faire bouger le corps de serpent
move $t1 $s5	#l'ancienne position X de la tete
move $t2 $s6	#l'ancienne position Y de la tete 
lw $t0 tailleSnake
sub $t0 $t0 1	#taille de serpent - 1
li $t3 1
#***-------------------------------------------------------------------------------------------------------------***
#parcourir le corps de serpent (tete non incluse) cest la raison pour laquelle on initialise t3 a 1
decal: bgt $t3 $t0 erase
mul $t3 $t3 4
lw $t4 snakePosX($t3) #position X de la piece d'ordre ($t4) de corps (tete non incluse)
lw $t5 snakePosY($t3) #position Y de la piece d'ordre ($t4) de corps (tete non incluse)
sw $t1 snakePosX($t3) #mettre a jour la positon X (car notre serpent bouge !)
sw $t2 snakePosY($t3) #mettre a jour la position Y
move $t1 $t4
move $t2 $t5
div $t3 $t3 4
add $t3 $t3 1			
j decal
#***-------------------------------------------------------------------------------------------------------------***
#***-------------------------------------------------------------------------------------------------------------***
erase:
lw $ra ($sp)
jr $ra
#***-------------------------------------------------------------------------------------------------------------***
############################### conditionFinJeu ################################
# Param?tres: Aucun
# Retour: $v0 La valeur 0 si le jeu doit continuer ou toute autre valeur sinon.
################################################################################

conditionFinJeu:

li $v0 1
li $t0 1 #simple initialisation
#***-------------------------------------------------------------------------------------------------------------***
#la tete de serpent ne doit pas depasser la bordure de la grille
lw $t3 tailleGrille 

#***-------------------------------------------------------------------------------------------------------------***
lw $t1 snakePosX($0)
lw $t2 snakePosY($0)
#***-------------------------------------------------------------------------------------------------------------***
bgt $t1 $t3 finf
bgt $t2 $t3 finf
bltz $t1 finf
bltz $t2 finf
#***-------------------------------------------------------------------------------------------------------------***
#la tete de serpent touche une partie de son corps
lw $t5 tailleSnake
loopc: bge $t0 $t5 obstacle
mul $t0 $t0 4
lw $t3 snakePosX($t0)
lw $t4 snakePosY($t0)
div $t0 $t0 4
add $t0 $t0 1
bne $t3 $t1 loopc
bne $t4 $t2 loopc
j finf
#***-------------------------------------------------------------------------------------------------------------***
#la tete de serpent ne doit pas rentrer en contacte avec un obstacle
obstacle:
li $t0 0 #simple initialisation
lw $t3 numObstacles
li $s4 0
loopf:
bge $t0 $t3 finloop
lw $t5 obstaclesPosX($s4)
lw $t6 obstaclesPosY($s4)
add $t0 $t0 1
add $s4 $s4 4
bne $t1 $t5 loopf
bne $t2 $t6 loopf
j finf 
#***-------------------------------------------------------------------------------------------------------------***
finloop:
li $v0 0
#***-------------------------------------------------------------------------------------------------------------***
finf:
jr $ra
#***-------------------------------------------------------------------------------------------------------------***
############################### affichageFinJeu ################################
# Param?tres: Aucun
# Retour: Aucun
# Effet de bord: Affiche le score du joueur dans le terminal suivi d'un petit
#                mot gentil (Exemple : ?Quelle pitoyable prestation !?).
# Bonus: Afficher le score en surimpression du jeu.
################################################################################

affichageFinJeu:

#***-------------------------------------------------------------------------------------------------------------***
sw $ra ($sp)
#***-------------------------------------------------------------------------------------------------------------***

jal resetAffichage
#***-------------------------------------------------------------------------------------------------------------***
#	Dans le terminal
li $v0 4
la $a0 Message
syscall
li $v0 1
lw $a0 scoreJeu
syscall



#***-------------------------------------------------------------------------------------------------------------***
#	Dans le display
#***-------------------------------------------------------------------------------------------------------------***
# Affichage de serpent
#***-------------------------------------------------------------------------------------------------------------***
lw $a0 colors + green # En vert
li $s0 0 # index 0
li $t1 140 # index 140 (35 ?l?ments dans le tableau des coordonn?es)
loopSnake:
bge $s0 $t1 endLoopSnake
lw $a1 drawSnakePosX($s0)
lw $a2 drawSnakePosY($s0)
jal printColorAtPosition
addu $s0 $s0 4 # parcourir le tableau des coordonn?es X et Y
j loopSnake
endLoopSnake:
#***-------------------------------------------------------------------------------------------------------------***
lw $a0 colors + lightYellow # En jaune clair
li $s0 0
li $t1 8
loopEyes:
bge $s0 $t1 endLoopEyes
lw $a1 drawSnakeEyesPosX($s0)
lw $a2 drawSnakeEyesPosY($s0)
jal printColorAtPosition
addu $s0 $s0 4
j loopEyes
endLoopEyes:
#***-------------------------------------------------------------------------------------------------------------***
lw $a0 colors + red # En rouge
li $s0 0
li $t1 28
loopRed:
bge $s0 $t1 endLoopRed
lw $a1 drawXPosX($s0)
lw $a2 drawYPosY($s0)
jal printColorAtPosition
addu $s0 $s0 4
j loopRed
endLoopRed:
#***-------------------------------------------------------------------------------------------------------------***


#***-------------------------------------------------------------------------------------------------------------***
# Recuperer chaque chiffre du score
lw $t0 scoreJeu
li $t1 10
div $t0 $t1 # Diviser par 10
mfhi $s0 # Mettre le reste (registre HI) dans $s0 (Unite)
mflo $s1 # Mettre le quotient (registre LO) dans $s1 (Dizaine)
#***-------------------------------------------------------------------------------------------------------------***

# Conditions chiffres de droite (Unites)
# Comparer le reste stocke dans $s0 avec chaque chiffre de 0 et 9

beqz $s0 drawZeroRight
li $t0 1
beq $s0 $t0 drawOneRight
li $t0 2
beq $s0 $t0 drawTwoRight
li $t0 3
beq $s0 $t0 drawThreeRight
li $t0 4
beq $s0 $t0 drawFourRight
li $t0 5
beq $s0 $t0 drawFiveRight
li $t0 6
beq $s0 $t0 drawSixRight
li $t0 7
beq $s0 $t0 drawSevenRight
li $t0 8
beq $s0 $t0 drawEightRight
li $t0 9
beq $s0 $t0 drawNineRight

# Conditions chiffres de gauche (Dizaine)
# Comparer le quotient stock dans $s1 avec chaque chiffre de 0 a 9
#***-------------------------------------------------------------------------------------------------------------***
left: 	#afficher le chiffre a gauche
beqz $s1 drawZeroLeft
li $t0 1
beq $s1 $t0 drawOneLeft
li $t0 2
beq $s1 $t0 drawTwoLeft
li $t0 3
beq $s1 $t0 drawThreeLeft
li $t0 4
beq $s1 $t0 drawFourLeft
li $t0 5
beq $s1 $t0 drawFiveLeft
li $t0 6
beq $s1 $t0 drawSixLeft
li $t0 7
beq $s1 $t0 drawSevenLeft
li $t0 8
beq $s1 $t0 drawEightLeft
li $t0 9
beq $s1 $t0 drawNineLeft

#***-------------------------------------------------------------------------------------------------------------***
drawZeroRight:
li $s2 0	#index qui commence de zero
li $s3 48	#index s'arrete une fois qu'on a parcouru tout le tableau (4*12)
lw $a0 colors + red	#on met le pixel en rouge
#***-------------------------------------------------------------------------------------------------------------***
loopDrawZeroR: bge $s2 $s3 left	# apres avoir affich? le chiffre de droite, on passe au chiffre de gauche
lw $a1 drawZeroLRPosX($s2)	# on met dans $a1 les coordonn?es X du 0
lw $a2 drawZeroRPosY($s2)	# Les coorodonn?es Y du 0
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawZeroR
#***-------------------------------------------------------------------------------------------------------------***
drawOneRight:
li $s2 0
li $s3 24
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawOneR: bge $s2 $s3 left
lw $a1 drawOneLRPosX($s2)
lw $a2 drawOneRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawOneR

drawTwoRight:
li $s2 0
li $s3 44
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawTwoR: bge $s2 $s3 left
lw $a1 drawTwoLRPosX($s2)
lw $a2 drawTwoRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawTwoR

drawThreeRight:
li $s2 0
li $s3 44
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawThreeR: bge $s2 $s3 left
lw $a1 drawThreeLRPosX($s2)
lw $a2 drawThreeRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawThreeR

drawFourRight:
li $s2 0
li $s3 36
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawFourR: bge $s2 $s3 left
lw $a1 drawFourLRPosX($s2)
lw $a2 drawFourRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawFourR

drawFiveRight:
li $s2 0
li $s3 44
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawFiveR: bge $s2 $s3 left
lw $a1 drawFiveLRPosX($s2)
lw $a2 drawFiveRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawFiveR

drawSixRight:
li $s2 0
li $s3 48
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawSixR: bge $s2 $s3 left
lw $a1 drawSixLRPosX($s2)
lw $a2 drawSixRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawSixR

drawSevenRight:
li $s2 0
li $s3 32
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawSevenR: bge $s2 $s3 left
lw $a1 drawSevenLRPosX($s2)
lw $a2 drawSevenRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawSevenR

drawEightRight:
li $s2 0
li $s3 52
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawEightR: bge $s2 $s3 left
lw $a1 drawEightLRPosX($s2)
lw $a2 drawEightRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawEightR

drawNineRight:
li $s2 0
li $s3 48
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawNineR: bge $s2 $s3 left
lw $a1 drawNineLRPosX($s2)
lw $a2 drawNineRPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawNineR

#***-------------------------------------------------------------------------------------------------------------***
#***-------------------------------------------------------------------------------------------------------------***
#***-------------------------------------------------------------------------------------------------------------***
drawZeroLeft:
li $s2 0
li $s3 48
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawZeroL: bge $s2 $s3 scorePopup	# Pour afficher le message en popup, on en a fini avec les chiffres!
lw $a1 drawZeroLRPosX($s2)
lw $a2 drawZeroLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawZeroL
#***-------------------------------------------------------------------------------------------------------------***
drawOneLeft:
li $s2 0
li $s3 24
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawOneL: bge $s2 $s3 scorePopup
lw $a1 drawOneLRPosX($s2)
lw $a2 drawOneLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawOneL

drawTwoLeft:
li $s2 0
li $s3 44
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawTwoL: bge $s2 $s3 scorePopup
lw $a1 drawTwoLRPosX($s2)
lw $a2 drawTwoLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawTwoL

drawThreeLeft:
li $s2 0
li $s3 44
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawThreeL: bge $s2 $s3 scorePopup
lw $a1 drawThreeLRPosX($s2)
lw $a2 drawThreeLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawThreeL

drawFourLeft:
li $s2 0
li $s3 36
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawFourL: bge $s2 $s3 scorePopup
lw $a1 drawFourLRPosX($s2)
lw $a2 drawFourLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawFourL

drawFiveLeft:
li $s2 0
li $s3 44
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawFiveL: bge $s2 $s3 scorePopup
lw $a1 drawFiveLRPosX($s2)
lw $a2 drawFiveLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawFiveL

drawSixLeft:
li $s2 0
li $s3 48
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawSixL: bge $s2 $s3 scorePopup
lw $a1 drawSixLRPosX($s2)
lw $a2 drawSixLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawSixL

drawSevenLeft:
li $s2 0
li $s3 32
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawSevenL: bge $s2 $s3 scorePopup
lw $a1 drawSevenLRPosX($s2)
lw $a2 drawSevenLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawSevenL

drawEightLeft:
li $s2 0
li $s3 52
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawEightL: bge $s2 $s3 scorePopup
lw $a1 drawEightLRPosX($s2)
lw $a2 drawEightLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawEightL

drawNineLeft:
li $s2 0
li $s3 48
lw $a0 colors + red
#***-------------------------------------------------------------------------------------------------------------***
loopDrawNineL: bge $s2 $s3 scorePopup
lw $a1 drawNineLRPosX($s2)
lw $a2 drawNineLPosY($s2)
jal printColorAtPosition
addu $s2 $s2 4
j loopDrawNineL

#***-------------------------------------------------------------------------------------------------------------***
#	Petit message popup

scorePopup:
lw $t0 scoreJeu
blt $t0 10 assezBien # Si le score est < 10
bge $t0 20 bien # Si le score est 20 >= scoreJeu < 50

assezBien:
li $v0 55 # appel systeme 55: afficher un message d'erreur, d'inforamtion, ou une question
la $a0 messageABien # parametre $a0 pour la chaine de caractere a afficher
li $a1 1 # parametre $a1 pour indiquer que c'est un message d'information
syscall
j finG

bien:
bge $t0 50 excellent # Si le score >= 50
li $v0 55
la $a0 messageBien
li $a1 1
syscall
j finG

excellent:
li $v0 55
la $a0 messageExcellent
li $a1 1
syscall


#***-------------------------------------------------------------------------------------------------------------***
finG:
#***-------------------------------------------------------------------------------------------------------------***

lw $ra ($sp)
jr $ra
