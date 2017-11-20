org 100H

	start:
		MOV AH, 9
		MOV DX, hello
		INT 21H

		MOV DX, ent
		INT 21H

		MOV DX, podaj
		INT 21H
		
		MOV DX, ent
		INT 21H
		
		MOV CX, 0

     pushloop:
		MOV  AH, 1
		INT  21H

		CMP  AL, 13
		JE   poploop
	
		SUB  AL, 48
		XOR  AH, AH
		PUSH AX

		INC  CX
		MOV  [stacount], CX

		JMP  pushloop
		
      poploop:
		POP BX

		MOV CX, [stacount]
		DEC CX,
		MOV [stacount], CX
		CMP CX, 0

		JE koniec

		JMP poploop
       koniec:    
		MOV AH, 9
		MOV DX, info
		INT 21H

		MOV AH, 2
		MOV DL, [stacount]
		ADD DL, 48
		INT 21H

		MOV AX, 4C00H
		INT 21H



hello    db "Witaj w kalkulatorze.$"
podaj    db "Podaj liczbe:$"
info     db "Koniec. $"
ent      db  10,13,36
stacount db  0