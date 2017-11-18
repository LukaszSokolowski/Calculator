org 100h

	start:		
		MOV AH, 9	;Funkcja dosowa wypisujaca lancuch znak¢w do momentu napotkania znkau $
		MOV DX, hello	;Wrzuc do rejestru DX wartosc zmiennej z komunikatem powitalnym
		INT 21H		;Przerwanie DOS

		MOV DX, ent	;Zmienna ent to kombinacja powrotu kursora oraz przejscia do nowej lini (enter)
		INT 21H		;Przerwanie DOS

		MOV DX, stopinfo;Przenies do DX wartosc zmiennej informujacej o sposobie zakonczenia wprowadzania
		INT 21H		;Przerwanie DOS
	
		
	input:
		XOR AL, AL	;Wyczysc rejestr AL poniewaz prowadzi tu rowniez instrukcja
				;obslugujaca wyjatek wprowadzenia blednej liczby (error->clrstack)
				;ktora zawiera warosci w AL
		MOV AH, 9	;Funkcja DOSowa wypisujaca z DX lancuch znak¢w
				;musimy powtorzyc dekla	racje AH=9 poniewaz mozemy tu skoczyc
				;z etykiety error gdzie w AH jest 1

		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV DX, getnumb	;Do rejestru DX kopiuj wartosc zmiennej getnumb
		INT 21H		;Przerwanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS
		
		MOV CX, 0	;Wartosc 0 do rejestru CX, bedzie on wskazywac na ilosc pobranych cyfr przez program


      pushloop:	 		;W petli pobieramy znaki i wrzucamy na stos
		MOV AH, 1	;Funkcja oczekjaca na znak ze standardowego wejscia
		INT 21H		;Przerwanie DOS
		
		CMP AL, 13	;Jesli jest to enter konczymy wpisywanie znakow
		JE  poploop	;Przeskocz do etykiety zrzucania cyfr ze stosu
		CMP AL, 48	;Sprawdzamy czy wprowadzony znak jest cyfra badajac
		JL  error	;przedzial wartosci dla liczb w tablicy ASCII jesli jest mniejszy to nie jest cyfra	
		CMP AL, 57	;Porownaj czy wprowadzony znak jest wartoscia odpowiadajaca liczbie
		JG  error	;Jesli wiekszy to wprowadzony znak nie jest liczb¥ i przejdz do etykiety blad
		
		INC CX		;Poprawnie pobralismy cyfre wiec zwiekszam licznik cyfr
		MOV [count], CX ;Skopiuj do zmiennej wartosc rejestru CX (ilosc liczb na stosie)

		SUB AL, 48	;Uzyskujemy cyfre ze znaku ASCII

		XOR AH, AH	;Zerujemy g¢rna czesc rejestru AX czyli AH po to aby uzyskac
				;w calym rejestrze wartosc naszej cyfry bo obecnie w AH mamy
				;wartosc funkcji wywolujacej pobranie znaku tak wiec 
				;dla pobranej 2 mielibysmy np 100000002 w AX
				;ale uzywajac XOR mamy same zera w AH oraz 00000002 w AL

		PUSH AX		;Wrzucamy na stos rejestr AX
		JMP  pushloop	;Kolejny krok petli 
		
				

       				;Aby stworzyc liczbe z cyfr przechowywanych na stosie musimy
				;kolejno przy zdejmowaniu ze stosu mnozyc dana cyfre razy 10 do potegi 
				;ilosci aktualnych liczb na stosie oraz dodawac w petli ten wynik do
				;zmiennej ktora po ostatnim zdjeciu ze stosu i dodaniu bedzie juz liczba ulozona
       poploop:			;z kolejno wprowadzonych cyfr

		POP BX		;Zrzuc wartosc ze stosu do rejestru BX
		DEC CX		;Zmniejsz CX czyli falge ilosci cyfr na stosie
		CMP CX,0	;Jesli jest rowne zero to zrzucone jest wszystko
		JE  endprogr	;!Przejdz do zakonczenia programu

		JMP poploop	;Jesli CX!=0 to przejdz do kolejnego kroku petli
		;TO DO
		;MNOZENIE LICZB ZDJECTYCH DO STOSU x10^cx I OBLICZANIE CALOSCIOWEJ LICZBY
		;POPRZES SUME POMNOZONYCH CZESCI 
		
      endprogr:
		MOV AX, 4C00H   ;Zwracamy kontrole do DOS (stop program)
		INT 21H		;Przerwanie DOS

	 error:
		MOV AH, 9	;Funkcja wywolujaca lancuch znak¢w
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV DX, wrong	;Wrzuc do DX informacje o blednym parametrze
		INT 21H		;Przewanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS
		
		MOV DX, askuser	;Do DX kopiuj lancuch z pytaniem czy uzytkownik chce powtorzyc wpisywanie liczb
		INT 21H		;Przerwanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przewanie DOS

		XOR AL,AL	;Wyczysc AL

		MOV AH, 1	;Funkcja pobierajaca znak z wejscia 
				;Jesli bedzie to y to wracamy do poczatku wprowadzania danej liczby jesli n to konczymy program
		INT 21H		;Przerwanie DOS
		
		CMP AL, 116	;116 odpowiada w ascii literze t
		JE  clrstack	;Przejdz do wyczyszczenia stosu -> pobieraj cyfry jeszcze raz na "czysty" stos
		CMP AL, 84	;84  odpowiada w ascii literze T
		JE  clrstack	;Przejdz do wyczyszczenia stosu -> pobieraj cyfry na "czysty" stos

		JMP endprogr	;Jesli uzytkownik poda n lub inny symbol to przejdz do
				;etykiety zakonczenia programu



    clrstack:			;Jesli uzytkownik chce jeszcze raz wprowadzac iczby 
				;warto (???) wyczyscic stos ze wczesniej wprowadzonych wartosci

		POP BX		;Zdejmij ze stosu do BX
		XOR BX,BX	;Zeruj BX

		CMP CX,0	;Porownaj czy wartosc rejestru CX wynosi 0
		JE  input	;Jesli tak to przejdz do ponownego wprowadzania	cyfr
		DEC CX		;Zmniejsz o 1 rejestr CX

		JMP clrstack	;Przejdz do kolejnego kroku (tylko gdy JE input nie jest spelnione)

wrong    db  "Podales niepoprawny argument.$"
hello    db  "Witaj! Ten program jest prostym kalkulatorem.$"
getnumb  db  "Podaj liczbe: $"
ent    	 db  10,13,36 
stopinfo db  "Wcisnij ENTER, aby zakonczyc wpisywanie liczby.$"
askuser	 db  "Czy chcesz powt¢rzyc wpisywanie liczby? t - tak, n - nie.$"
num1     db  0,36    ;W tej zmiennej przechowujemy pierwsza wprowadzona liczbe
num2     db  0,36    ;W tej zmiennej przechowujemy druga wprowadzona liczbe
count    db  0,36    ;Przechowywac bedzie ilosc cyfr na stosie