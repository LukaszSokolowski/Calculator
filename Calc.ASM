org 100h

	start:		
		MOV AH, 9	;Funkcja dosowa wypisujaca lancuch znak¢w do momentu $
		MOV DX, hello	;Wrzuc do rejestru DX wartosc zmiennej z komunikatem powitalnym
		INT 21H		;Przerwanie DOS

		MOV DX, ent	;Zmienna ent to kombinacja powrotu 
				;kursora oraz przejscia do nowej lini (enter)
		INT 21H		;Przerwanie DOS

		MOV DX, stopinfo;Przenies do DX wartosc zmiennej 
				;informujacej o sposobie zakonczenia wprowadzania
		INT 21H		;Przerwanie DOS
	
		
	input:
		XOR AL, AL	;Wyczysc rejestr AL poniewaz prowadzi tu rowniez instrukcja
				;obslugujaca wyjatek wprowadzenia blednej liczby (error->clrstack)
				;ktora zawiera warosci w AL
		MOV AH, 9	;Funkcja DOSowa wypisujaca z DX lancuch znak¢w
				;musimy powtorzyc deklaracje AH=9 poniewaz mozemy tu skoczyc			
				;z etykiety error gdzie w AH jest 1

		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV DX, getnumb	;Do rejestru DX kopiuj lancuch getnumb
		INT 21H		;Przerwanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV CX, 0	;Wartosc 0 do rejestru CX, bedzie on wskazywac na 
				;ilosc pobranych cyfr przez program


      pushloop:	 		;W petli pobieramy znaki i wrzucamy na stos
		MOV AH, 1	;Funkcja oczekjaca na znak ze standardowego wejscia
		INT 21H		;Przerwanie DOS
		
		CMP AL, 13	;Jesli jest to enter konczymy wpisywanie znakow
		JE  poploop	;Przeskocz do etykiety zrzucania cyfr ze stosu
		CMP AL, 48	;Sprawdzamy czy wprowadzony znak jest cyfra badajac
		JL  error	;przedzial wartosci dla cyfr w tablicy ASCII 
				;jesli jest mniejszy to nie jest cyfra	
		CMP AL, 57	;Porownaj czy wprowadzony znak jest wartoscia odpowiadajaca cyfrze
		JG  error	;Jesli wiekszy to wprowadzony znak nie 
				;jest cyfra i przejdz do etykiety error
		
		INC CL 		;Poprawnie pobralismy cyfre wiec zwiekszam licznik cyfr
		MOV [count],CL	;MOV [miennej wartosc rejestru CX (ilosc liczb na stosie)
		SUB AL, 48	;Uzyskujemy cyfre ze znaku ASCII

		XOR AH, AH	;Zerujemy g¢rna czesc rejestru AX czyli AH po to aby uzyskac
				;w calym rejestrze wartosc naszej cyfry bo obecnie w AH mamy
				;wartosc funkcji wywolujacej pobranie znaku tak wiec 
				;dla pobranej 2 mielibysmy np 100000002 w AX
				;ale uzywajac XOR mamy same zera w AH oraz 00000002 w AL
		PUSH AX		;Wrzucamy na stos rejestr AX
 	        JMP pushloop	;Kolejny krok petli 
			
       				;*Aby stworzyc liczbe z cyfr przechowywanych na stosie musimy
				;*kolejno przy zdejmowaniu ze stosu mnozyc dana cyfre razy 10 do potegi 
				;*ilosci aktualnych liczb na stosie oraz dodawac w petli ten wynik do
				;*zmiennej ktora po ostatnim zdjeciu ze 
				;stosu i dodaniu bedzie juz liczba ulozona
      				;*z kolejno wprowadzonych cyfr
      poploop:
		CMP CL,0	;Porownaj czy stos czysty
		JE  choose	;Jesli tak to koniec programu
		POP BX		;Zdejmij wartosc z BX (pojedyncza cyfra z wejscia)
		MOV CH, CL
	_mul:
		CMP CH, 1	;Mnozymy (n-1) razy gdzie n to ilosc liczb na stosie 
		JE  dalej	;Jesli spelniony warunek przejdz do dodania wyniku
		MOV AX, 10	;Przenies do AX wartosc 10
		MUL BX		;Pomnoz BX razy wartosc AX i wynik do AX
		xor dx,dx	;Zerowanie rejestru DX
		MOV BX, AX	;Przenies do BX aktualny wynik mnozenia liczby
		DEC CH		;Zmniejsz licznik mnozen o 1
		JMP _mul	;Przejdz do kolejnego kroku mnozenia
	dalej:
		ADD [temp] , BX ;Dodaj do zmiennej aktualna wartosc liczby
		MOV [count], CL  ;3 2 1 przeno˜ do count aktualn¥ ilosc liczb na stosie
		DEC CL		;osiaga wartosc 0 dla 1 na stosie Zmniejsz wartosc licznika stosu o 1

		JMP poploop	;Przejdz do poczatku etykiety
		
	choose:
		XOR CX, CX        ;Wyczysc rejestr CX
		MOV AL, [numbers] ;Przenies do AL ilosc liczb do pobrania
		CMP AL, 2	  ;Jesli rowne 2 to przejdz do pierwszej
		JE  first	  ;Przejdz do etykiety first
		MOV AX, [temp]	  ;Przenies do AX wartosc zliczby wprowadzonej przez uzytkownika
		MOV [num2], AX	  ;Przenies do zmiennej [num2] wartosc rejestru AX
		JMP operat	  ;Przejdz do etykiety wyboru operacji
	first:
		MOV AX, [temp]	  ;Przenies do AX wartosc zmiennej temp czyli liczby uzytkownika
		MOV [num1], AX	  ;Przenies do zmiennej num1
		XOR AX, AX	  ;Wyczysc rejestr
		MOV [temp], AX    ;Wyczysc zmienna tymczasowa
		MOV AL, [numbers] ;Przenies do AL informacje o ilosci liczb do pobrania
		DEC AL		  ;Zmniejsz o 1 liczbe zmiennych
		MOV [numbers], AL ;Przenies z rejestru AL zmniejszona liczbe do zmiennej numbers
		JMP input         ;Przejdz do wprowadzania kolejnej liczby

	operat:  
		MOV AH, 9	  ;Funkcja wywolujaca lancuch z DX
		MOV DX, oper	  ;Przenies do DX zapytanie o rodzaj operacji
		INT 21H		  ;Przerwanie DOS
		
		MOV DX, ent	  ;Przenies do DX zmienna z symbolami (enter)
		INT 21H		  ;Przerwanie DOS
	  
		MOV AH, 1	  ;Funkcja wczytaj znak
		INT 21H		  ;Przerwanie DOS
			
		MOV AH, 9
		MOV DX, ent
		INT 21H
		
		CMP AL, 43        ;43 to znak dodawania
		JE  xadd	  ;Przejdz do dodawania

		CMP AL, 45	  ;45 to znak minusa
		JE  xsub	  ;Przejdz do odejmowania

		CMP AL, 42	  ;42 to znak mnozenia
		JE  xmul	  ;Przejdz do mnozenia

		CMP AL, 47	  ;47 to znak dzielenia
		JE  xdiv	  ;Przejdz do dzielenia

		JMP endprogr	  ;Jesli wprowadzony znak bledny przejdz do zakonczenia programu

	xadd:
		MOV AX, [num1]
		MOV BX, [num2]	  ;DODAWANIE
		ADD AX, BX
		JMP cont
	xsub:
		MOV AX, [num1]
		MOV BX, [num2]	  ;ODEJMOWANIE
		SUB AX, BX
		JMP cont
	xmul:
		MOV AX, [num1]
		MOV BX, [num2]	  ;MNOZENIE
		MUL BX
		JMP cont

	xdiv:
		MOV AX, [num1]
		MOV BX, [num2]    ;DZIELENIE
		DIV BX
		JMP cont
	cont:
		MOV CX, 0	;Przenies 0 do CX
		MOV BX, 10	;Przenies dzielnik do BX
	
       pushwyni:
		XOR DX, DX	;Wyzeruj DX
		DIV BX		;Podziel AX przez BX
		PUSH DX		;Wrzuc reszte
		INC CX		;Zwieksz licznik
		CMP AX, 0 	;Porownaj czy licznik rowny 0
		JA pushwyni	;Jesli wiekszy dziel dalej


		MOV AH, 9	;Funkcja wypisz lancuch
		MOV DX, result	;Informacja o wyniku
		INT 21H

		MOV AH, 2	;Wypisz znak
	echow:
		POP DX		;Zrzuc do DX
		XOR DH, DH	;Zeruj gore rejestru DX czyli DH
		ADD DX, 48	;Dodaj 48 tak aby wyswietlic cyfre
		INT 21H		;Przerwanie DOS
	loop echow	

			
      endprogr: 		
		MOV AH, 9	;Funkcja wypisz lancuch z DX
		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV DX, dziekuje;Napis pozegnalny
		INT 21H		;Przerwanie DOS

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
		
		MOV DX, askuser	;Do DX kopiuj lancuch z pytaniem czy uzytkownik 
				;chce powtorzyc wpisywanie liczb
		INT 21H		;Przerwanie DOS
		
		MOV DX, ent	;Enter
		INT 21H		;Przewanie DOS

		XOR AL,AL	;Wyczysc AL

		MOV AH, 1	;Funkcja pobierajaca znak z wejscia 
				;Jesli bedzie to y to wracamy do poczatku 
				;wprowadzania danej liczby jesli n to konczymy program
		INT 21H		;Przerwanie DOS
		
		CMP AL, 116	;116 odpowiada w ascii literze t
		JE  clrstack	;Przejdz do wyczyszczenia stosu -> 
				;pobieraj cyfry jeszcze raz na "czysty" stos
		CMP AL, 84	;84  odpowiada w ascii literze T
		JE  clrstack	;Przejdz do wyczyszczenia stosu -> 
				;pobieraj cyfry na "czysty" stos

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
getnumb  db  "Podaj liczbe:$"
stopinfo db  "Wcisnij ENTER, aby zakonczyc wpisywanie liczby.$"
askuser	 db  "Czy chcesz powt¢rzyc wpisywanie liczby? t - tak, n - nie.$"
result   db  "Wynik to:  $"
oper	 db  "Wybierz operacje na tych dwoch liczbach *,/,-,+ :$"
dziekuje db  "Dziekuje bardzo.$"
ent      db  10,13,36
num1     dw  0
num2     dw  0
count    db  0
temp     dw  0
numbers  db  2