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
				;musimy powtorzyc dekla	racje AH=9 poniewaz mozemy tu skoczyc				;z etykiety error gdzie w AH jest 1

		MOV DX, ent	;Enter
		INT 21H		;Przerwanie DOS

		MOV DX, getnumb	;Do rejestru DX kopiuj lancuch getnumb
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
		JL  error	;przedzial wartosci dla cyfr w tablicy ASCII jesli jest mniejszy to nie jest cyfra	
		CMP AL, 57	;Porownaj czy wprowadzony znak jest wartoscia odpowiadajaca cyfrze
		JG  error	;Jesli wiekszy to wprowadzony znak nie jest cyfra i przejdz do etykiety error
		
		INC CX		;Poprawnie pobralismy cyfre wiec zwiekszam licznik cyfr
				;MOV [miennej wartosc rejestru CX (ilosc liczb na stosie)
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
				;*zmiennej ktora po ostatnim zdjeciu ze stosu i dodaniu bedzie juz liczba ulozona
       poploop:			;*z kolejno wprowadzonych cyfr

		POP BX		;Zrzuc wartosc ze stosu do rejestru BX
		MOV [count], CX ;Przenies wartosc o ilosci liczb na stosie do zmiennej count
		JMP create	;Przejdz do tworzenia liczby
	ready:
		ADD [temp], BX	;Dodaj kolejne czesci policzonej liczby
		XOR BX, BX
		DEC CX		;Zmniejsz CX czyli falge ilosci cyfr na stosie
		CMP CX, 0	;Jesli jest rowne zero to zrzucone jest wszystko
		JE  choose	;!Przejdz do etykiety sterujacej wprowadzaniem

    		JMP poploop	;Jesli CX!=0 to przejdz do kolejnego kroku petli

	create:			;Tworzymy liczbe poprzez mnozenie przyklad dla 7 
		MOV AL, 10	;Do AL wartosc 10
		MUL BX		;Pomnoz rejestr BX przez wartosc rejestru AL i zapisz w AX 7*10=70
		MOV BX, AX	;BX = 70 
		MOV DX, [count]	;Do DX wrzuc ilosc pomnozen 
		DEC DX		;Zmniejsz rejestr DX o 1
		MOV [count],DX  ;Wpisz wartosc rejestru DX do zmiennej count
		CMP DX, 0	;Porownaj czy jest rowny 0
		JE ready	;Jesli tak to obliczenie tej czesci liczby gotowe i przejdz do etykiety ready

     		JMP create	;Jesli nie to przejdz do kolejnego kroku i mnoz dalej
		
	choose:
		XOR DX, DX
		MOV DL, [numbers]
		INC DL
		MOV [numbers], DL
		CMP DL, 1

		JE  first

	 second:
		MOV AX, [temp] 
		MOV BX, num2
		MOV BX, [temp]
				;przeskocz do wyboru operacji
		JMP endprogr 

	 first:	
		MOV AX, [temp]
		MOV BX, num1
		MOV BX, [temp]
		
		XOR AX, AX		;zeruj wartosc zmiennej temp przed jej ponownym uzyciem

		MOV AH, 9 
		MOV DX, nextnum
		INT 21H

		MOV DX, ent
		INT 21H

		JMP pushloop
      endprogr: 
		MOV AH, 9
		MOV DX, ent
		INT 21H

		MOV DX, koniec
		INT 21H

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
getnumb  db  "Podaj liczbe:$"
ent    	 db  10,13,36 
stopinfo db  "Wcisnij ENTER, aby zakonczyc wpisywanie liczby.$"
askuser	 db  "Czy chcesz powt¢rzyc wpisywanie liczby? t - tak, n - nie.$"
num1     db  0    ;W tej zmiennej przechowujemy pierwsza wprowadzona liczbe
num2     db  0    ;W tej zmiennej przechowujemy druga wprowadzona liczbe
count    db  0    
numbers	 db  0    
koniec   db  "Koniec.$"
temp     db  0    ;Zmienna przechowujaca aktualna liczbe pobrana od uzytkownika
nextnum  db  "Podaj drug¥ liczb©:$"