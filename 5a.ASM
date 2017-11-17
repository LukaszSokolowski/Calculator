org 100h

	start:		
		MOV AH, 9	;Funkcja wypisuj¥ca ˆaäcuch znak¢w do momentu napotkania $
		MOV DX, hello	;Wrzu† do rejestru DX wartosc zmiennej powit
		INT 21H		;Przerwanie DOS

		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV DX, getnumb	;Do rejestru DX kopiuj wartosc zmiennej podaj
		INT 21H		;Przerwanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS
		
		MOV DX, stopinfo;Informacja o sposobie zakonczenia wprowadzania cyfr
		INT 21H		;Przerwanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

	loop:	
		MOV AH, 1	;Funkcja oczekj¥ca na znak ze standardowego wejscia
		INT 21H		;Przerwanie DOS
		
		CMP AL, 13	;Jesli jest to enter konczymy wpisywanie znakow;
		JE  ending	;Przeskocz do etykiety konca programu
		CMP AL, 48	;Sprawdzamy czy wprowadzony znak jest liczba badajac
		JL  error	;przedziaˆ wartosci dla liczb w tablicy ASCII	
		CMP AL, 57	;Porownaj czy wprowadzony znak jest wartoscia odpowiadajaca liczbie
		JG  error	;Jesli wiekszy to wprowadzony znak nie jest liczb¥ i przejdz do etykiety blad
		
		SUB AL, 48	;Uzyskujem cyfr© ze znaku ASCII

		XOR AH, AH	;Zerujemy g¢rn¥ cz©˜† rejestru AX czyli AH po to aby uzyska†
				;w calym rejestrze wartosc naszej cyfry bo obecnie w AH mamy
				;wartosc funkcji wywolujacej pobranie znaku tak wiec mielibysmy np 100000001 w AX
				;ale uzywajac XOR mamy same zera w AH oraz 00000001 w AL

		PUSH AX		;Wrzucamy na stos rejestr AX
		JMP  loop	;Kolejny krok petli 
		
	stackpop:

		
	ending:
		MOV AX, 4C00H   ;Zwracamy kontrol© do DOS (stop program)
		INT 21H		;Przerwanie DOS

	error:
		MOV AH, 9	;Funkcja wywoˆuj¥ca ˆaäcuch znak¢w
		MOV DX, ent	;Kombinacja znaku powrotu kursora oraz przejscia do kolejnej lini
		INT 21H		;Przerwanie DOS

		MOV DX, wrong	;Wrzuc do DX informacj© o bˆ©dnym parametrze
		INT 21H		;Przewanie DOS

		JMP ending	;Bezwarunkowo przejdz do etykiety koäcz¥cej program

		
wrong    db  "Podales niepoprawny argument.$"
hello    db  "Witaj! Ten program jest prostym kalkulatorem.$"
getnumb  db  "Podaj liczb©: $"
ent    	 db  10,13,36 
stopinfo db  "Wcisnij enter aby zakonczyc wpisywanie liczby.$"