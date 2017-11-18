org 100h

	start:		
		MOV AH, 9	;Funkcja wypisuj¥ca ˆaäcuch znak¢w do momentu napotkania $
		MOV DX, hello	;Wrzu† do rejestru DX wartosc zmiennej powit
		INT 21H		;Przerwanie DOS

		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV DX, stopinfo;Przenies do DX wartosc zmiennej informujacej o sposobie zakonczenia wprowadzania
		INT 21H		;Przerwanie DOS
	
		
	input:
		XOR AL, AL	;Wyczysc rejestr AL poniewaz prowadzi tu rowniez instrukcja
				;obslugujaca wyjatek wprowadzenia blednej liczby
		MOV AH, 9	;Funkcja DOSowa wypisuj¥ca z DX ˆaäcuch znak¢w
				;musimy powtorzyc deklaracje ah=9 poniewaz mozemy tu skoczyc
				;z etykiety error gdzie w AH jest 1

		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV DX, getnumb	;Do rejestru DX kopiuj wartosc zmiennej podaj
		INT 21H		;Przerwanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS
		
		MOV CX, 0	;Warto˜† 0 do rejestru CX, b©dzie on wskazywaˆ na ilosc pobranych cyfr przez program


      pushloop:	 		;W petli pobieramy znaki i wrzucamy na stos
		MOV AH, 1	;Funkcja oczekj¥ca na znak ze standardowego wejscia
		INT 21H		;Przerwanie DOS
		
		CMP AL, 13	;Jesli jest to enter konczymy wpisywanie znakow;
		JE  ending	;Przeskocz do etykiety konca programu
		CMP AL, 48	;Sprawdzamy czy wprowadzony znak jest liczba badajac
		JL  error	;przedziaˆ wartosci dla liczb w tablicy ASCII	
		CMP AL, 57	;Porownaj czy wprowadzony znak jest wartoscia odpowiadajaca liczbie
		JG  error	;Jesli wiekszy to wprowadzony znak nie jest liczb¥ i przejdz do etykiety blad
		
		INC CX		;Poprawnie pobralismy cyfre wiec zwiekszam licznik cyfr
		SUB AL, 48	;Uzyskujemy cyfr© ze znaku ASCII

		XOR AH, AH	;Zerujemy g¢rn¥ cz©˜† rejestru AX czyli AH po to aby uzyska†
				;w calym rejestrze wartosc naszej cyfry bo obecnie w AH mamy
				;wartosc funkcji wywolujacej pobranie znaku tak wiec mielibysmy np 100000001 w AX
				;ale uzywajac XOR mamy same zera w AH oraz 00000001 w AL

		PUSH AX		;Wrzucamy na stos rejestr AX
		JMP  pushloop	;Kolejny krok petli 
		
	ending:
		MOV AX, 4C00H   ;Zwracamy kontrol© do DOS (stop program)
		INT 21H		;Przerwanie DOS

	error:
		MOV AH, 9	;Funkcja wywoˆuj¥ca ˆaäcuch znak¢w
		MOV DX, ent	;Kombinacja znaku powrotu kursora oraz przejscia do kolejnej lini
		INT 21H		;Przerwanie DOS

		MOV DX, wrong	;Wrzuc do DX informacj© o bˆ©dnym parametrze
		INT 21H		;Przewanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS
		
		MOV DX, askuser	;Do DX ˆadujemy informacj© czy chce powtorzyc wpisywanie liczb
		INT 21H
		
		MOV DX, ent	;Enter
		INT 21H		;Przewanie DOS

		XOR AL,AL	;Wyczysc AL

		MOV AH, 1	;Funkcja pobierajaca znak z wejscia 
				;Jesli bedzie to y to wracamy do poczatku jesli n to konczymy program
		INT 21H		;Przerwanie DOS
		
		CMP AL, 116	;116 odpowiada t
		JE  clrstack	;Przejdz do wyczysczenia stosu
		CMP AL, 84	;84  odpowiada T
		JE  clrstack	;Przejdz do wyczyszczenia stosu

		JMP ending	;Jesli uzytkownik poda n lub inny symbol to przejdz do
				;etykiety zakonczenia programu

    clrstack:			;Jesli uzytkownik chce jeszcze raz wprowadzac iczby 
				;warto (???) wyczyscic stos ze wczesniej wprowadzonych wartosci

		POP BX		;Zdejmij ze stosu do BX
		XOR BX,BX	;Zeruj BX

		CMP CX,0	;Porownaj czy juz koniec
		JE  input	;Jesli tak to przejdz do ponownego wprowadzania
		DEC CX		;Zmniejsz o 1 rejestr CX

		JMP clrstack	;Przejdz do kolejnego kroku

wrong    db  "Podales niepoprawny argument.$"
hello    db  "Witaj! Ten program jest prostym kalkulatorem.$"
getnumb  db  "Podaj liczb©: $"
ent    	 db  10,13,36 
stopinfo db  "Wcisnij ENTER, aby zakonczyc wpisywanie liczby.$"
askuser	 db  "Czy chcesz powt¢rzy† wpisywanie liczby? t - tak, n - nie.$"