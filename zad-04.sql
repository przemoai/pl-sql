    Task 190
    set serveroutput on
    -- Zad. 190
    declare
        cursor c1 is select distinct count(*) ExamNum from egzaminy 
                        group by id_przedmiot
                        order by 1 desc
                        fetch first 3 rows only ;
        cursor c2(pExamNum number) is select nazwa_przedmiot from przedmioty p
                    inner join egzaminy e on p.id_przedmiot = e.id_przedmiotstudent.sql
                    group by nazwa_przedmiot
                    having count(*) = pExamNum ;
    begin
        for vc1 in c1 loop
             dbms_output.put_line('Exam number equals ' || to_char(vc1.ExamNum)) ;
            for vc2 in c2(vc1.ExamNum) loop
                 dbms_output.put_line(vc2.nazwa_przedmiot) ;
            end loop ;
        end loop ;
    end ;
     
    Alternatywnie:
    set serveroutput on
    -- Zad. 190
    declare
        vExamNum number ; 
        cursor c1 is select distinct count(*) ExamNum from egzaminy 
                        group by id_przedmiot
                        order by 1 desc
                        fetch first 3 rows only ;
        cursor c2 is select nazwa_przedmiot from przedmioty p
                    inner join egzaminy e on p.id_przedmiot = e.id_przedmiot
                    group by nazwa_przedmiot
                    having count(*) = vExamNum ;
    begin
        for vc1 in c1 loop
            vExamNum := vc1.ExamNum ; 
             dbms_output.put_line('Exam number equals ' || to_char(vc1.ExamNum)) ;
            for vc2 in c2 loop
                 dbms_output.put_line(vc2.nazwa_przedmiot) ;
            end loop ;
        end loop ;
    end ;
     
    Task 192
    declare
        cursor c1 is select nazwa_przedmiot, p.id_przedmiot, data_egzamin
                    from przedmioty p inner join egzaminy e
                    on p.id_przedmiot = e.id_przedmiot
                    where data_egzamin IN (select distinct data_egzamin
                                            from egzaminy e2
                                            where e2.id_przedmiot = p.id_przedmiot
                                            order by 1 desc
                                            fetch first 2 rows only
                                            )
                    order by 1, 3 desc ;
        cursor c2 (pIdPrzedmiot number, pExamDate date) is select distinct s.id_student, nazwisko, imie
                            from studenci s inner join egzaminy e on s.id_student = e.id_student
                            where e.data_egzamin = pExamDate and e.id_przedmiot = pIdPrzedmiot 
                            order by 2 ;
    begin
        for vc1 in c1 loop
            dbms_output.put_line(vc1.nazwa_przedmiot || ' (' || 
            to_char(vc1.data_egzamin, 'dd-mm-yyyy') || ')');
            for vc2 in c2(vc1.id_przedmiot, vc1.data_egzamin) loop
                dbms_output.put_line(vc2.nazwisko || ' ' || vc2.imie || '(' || vc2.id_student || ')') ; 
            end loop ;
        end loop ; 
    end ; 
     
    -- Krzysztof Matyjaszczyk Zad. 195
    declare
        cursor c1 is select distinct o.ID_OSRODEK
                     from OSRODKI o
                     inner join EGZAMINY e on e.ID_OSRODEK = o.ID_OSRODEK
                     where o.NAZWA_OSRODEK = 'CKMP';
        cursor c2(pIdOsrodek number) is select distinct count(*) liczba_egzaminow
                                        from egzaminy e
                                        where e.ID_OSRODEK = pIdOsrodek
                                        group by e.ID_STUDENT
                                        order by 1 desc
                                        fetch first 2 rows only;
        cursor c3(pIdOsrodek number, pLiczbaEgzaminow number) is select s.ID_STUDENT, s.IMIE, s.NAZWISKO
                                        from STUDENCI s
                                        inner join EGZAMINY e on e.ID_STUDENT = s.ID_STUDENT
                                        where e.ID_OSRODEK = pIdOsrodek
                                        group by s.ID_STUDENT, s.IMIE, s.NAZWISKO
                                        having count(*) = pLiczbaEgzaminow;
    begin
        for vc1 in c1 loop
            DBMS_OUTPUT.PUT_LINE('Osrodek o ID = ' || vc1.ID_OSRODEK);
            for vc2 in c2(vc1.ID_OSRODEK) loop
                    DBMS_OUTPUT.PUT_LINE('Exam number = ' || vc2.liczba_egzaminow);
                    for vc3 in c3(vc1.ID_OSRODEK, vc2.liczba_egzaminow) loop
                            DBMS_OUTPUT.PUT_LINE(vc3.ID_STUDENT || ', ' || vc3.IMIE || ', ' || vc3.NAZWISKO);
                    end loop;
            end loop;
        end loop;
    end;
     
    Task 194
    -- Zad. 194
    declare
        vStudNum number ; 
        cursor c1 is select distinct extract(year from data_egzamin) ExamYear from egzaminy
                    order by 1 desc ;
        cursor c2(pYear number, pStudNum number) is select nazwa_przedmiot from przedmioty p
                                        inner join egzaminy e on p.id_przedmiot = e.id_przedmiot
                                        where extract(year from data_egzamin) = pYear
                                        group by nazwa_przedmiot
                                        having count(distinct id_student) = pStudNum ;
    begin
        for vc1 in c1 loop
            dbms_output.put_line('Exam year is ' || to_char(vc1.ExamYear)) ;
            select max(count(distinct id_student)) into vStudNum from egzaminy
                                    where extract(year from data_egzamin) = vc1.ExamYear
                                    group by id_przedmiot
                                    order by 1 desc ;
            for vc2 in c2(vc1.ExamYear, vStudNum) loop
                dbms_output.put_line(vc2.nazwa_przedmiot || '(' || to_char(vStudNum) || ' students' || ')'); 
            end loop ; 
        end loop ; 
    end ; 
     
     
    Task 197
    declare
        vpoints number ;
        cursor c1 is select id_egzamin, zdal from egzaminy ;
    begin
        for vc1 in c1 loop
            if vc1.zdal = 'N' then
                vpoints := dbms_random.value(2,3) ;
            else
                vpoints := dbms_random.value(3, 5.01) ;
            end if ;
            update egzaminy e set punkty = vpoints 
                    where e.id_egzamin = vc1.id_egzamin ;
        end loop ; 
    end ; 
     
    Alternatywnie:
    declare
        vpoints number ;
        cursor c1 is select zdal from egzaminy for update of punkty;
    begin
        for vc1 in c1 loop
            if vc1.zdal = 'N' then
                vpoints := dbms_random.value(2,3) ;
            else
                vpoints := dbms_random.value(3, 5.01) ;
            end if ;
            update egzaminy e set punkty = vpoints 
                    where current of c1;
        end loop ; 
    end ; 
     
    Task 210
     
     declare
        vx number ; 
        cursor c1 is select id_przedmiot, nazwa_przedmiot from przedmioty ;
    begin
        for vc1 in c1 loop
            begin
                select distinct 1 into vx from egzaminy 
                    where id_przedmiot = vc1.id_przedmiot ;
            exception
                when no_data_found then
                    dbms_output.put_line(vc1.nazwa_przedmiot) ; 
            end ; 
        end loop ; 
    end ; 
     
    Task 211
    declare
        more_than_5 exception ; 
        cursor c1 is select g.id_egzaminator, nazwisko, imie, data_egzamin, 
                    count(distinct id_student) StudNum
            from egzaminatorzy g inner join egzaminy e  on g.id_egzaminator = e.id_egzaminator
            group by g.id_egzaminator, nazwisko, imie, data_egzamin ;
    begin
        for vc1 in c1 loop
            begin
                if vc1.StudNum > 5 then
                    raise more_than_5 ;
                end if ;
            exception
                when more_than_5 then 
                    dbms_output.put_line(vc1.nazwisko || ' ' || vc1.imie || '(' || vc1.id_egzaminator || ')') ; 
            end ;
        end loop ; 
    end ; 
     
     
     
     
     
    -- link do pobrania kontenera z oracle db free: https://container-registry.oracle.com/ords/ocr/ba/database/free
     
    -- Task 212 Krzysztof Matyjaszczyk
    declare
        vx number;
        vn_liczba_egzaminow number;
    begin
        select distinct 1 into vx from EGZAMINATORZY where NAZWISKO = 'Muryjas';
        for egzaminator in (select distinct ID_EGZAMINATOR from EGZAMINATORZY where NAZWISKO = 'Muryjas') loop
            select count(*) into vn_liczba_egzaminow from EGZAMINY where ID_EGZAMINATOR = egzaminator.ID_EGZAMINATOR;
            DBMS_OUTPUT.PUT_LINE('id egzaminatora: ' || egzaminator.ID_EGZAMINATOR || ', liczba egzaminow: ' || vn_liczba_egzaminow);
        end loop;
        exception
            when no_data_found then
                DBMS_OUTPUT.PUT_LINE('Egzaminator o podanym nazwisku nie istnieje');
    end;
     
     
    -- Task 213 Krzysztof Matyjaszczyk 
    declare
        vx number;
        vn_liczba_egzaminow number;
        e_osrodek_nie_istnieje exception;
    begin
        select distinct 1 into vx from OSRODKI where NAZWA_OSRODEK = 'LBS';
        for osrodek in (select ID_OSRODEK from OSRODKI where NAZWA_OSRODEK = 'LBS') loop
            begin
                select count(*) into vn_liczba_egzaminow from EGZAMINY where ID_OSRODEK = osrodek.ID_OSRODEK;
                if vn_liczba_egzaminow = 0 then
                    raise e_osrodek_nie_istnieje;
                end if;
                DBMS_OUTPUT.PUT_LINE('id osrodka: ' || osrodek.ID_OSRODEK || ', liczba egzaminow: ' || vn_liczba_egzaminow);
            exception
                when e_osrodek_nie_istnieje then
                    DBMS_OUTPUT.PUT_LINE('Ośrodek ' || osrodek.ID_OSRODEK || ' nie uczestniczył w egzaminach');
            end;
        end loop;
    exception
        when no_data_found then
            DBMS_OUTPUT.PUT_LINE('Ośrodek o podanej nazwie nie istnieje');
    end;
     
    Alternatywne rozwiązanie:
     
    declare
        v_liczba_osrodkow number;
        v_liczba_egzaminow number;
        c_nazwa_osrodka OSRODKI.NAZWA_OSRODEK%TYPE := 'LBS';
    begin
        select count(*)
        into v_liczba_osrodkow
        from OSRODKI o
        where upper(o.NAZWA_OSRODEK) = upper(c_nazwa_osrodka);
     
        if v_liczba_osrodkow = 0 then
            raise_application_error(-20000, 'Ośrodek o podanej nazwie ' || '(' || c_nazwa_osrodka || ')' || ' nie istnieje');
        end if;
     
        for vc_osrodek in (select o.ID_OSRODEK from OSRODKI o 
                            where upper(o.NAZWA_OSRODEK) = upper(c_nazwa_osrodka)) loop
    			begin
            select count(*)
            into v_liczba_egzaminow
            from EGZAMINY e
            where e.ID_OSRODEK = vc_osrodek.ID_OSRODEK;
     
            if v_liczba_egzaminow = 0 then
                raise_application_error(-20000, 'Ośrodek ' || '(' || c_nazwa_osrodka || ')' || ' o ID: ' || vc_osrodek.ID_OSRODEK || ' nie uczestniczył w egzaminach');
            end if;
     
            dbms_output.put_line('ID_OSRODKA: ' || vc_osrodek.ID_OSRODEK || ' -> ' || 'LICZBA EGZAMINOW = ' || v_liczba_egzaminow);
          exception
          		when others then
              		DBMS_OUTPUT.PUT_LINE (SQLERRM);
          end ;
        end loop;
     
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE (SQLERRM);
    end;
     
    --Task 214 Markiewicz Bartosz
     
    declare
        vx number;
        vn_id_egzamin egzaminy.id_egzamin%type ;
        vc_id_student egzaminy.id_student%type := '0000001';
        vn_id_przedmiot number := 1;
        vc_id_egzaminator varchar2 := '0001';
        vd_data_egzamin date := to_date('11/07/18','dd/mm/yy') ;
        vn_id_osrodek number := 1;
        vc_zdal varchar2 := 'T';
        vn_punkty number := 5;
        
    begin
        select distinct 1 into vx from egzaminy where zdal='T' and id_student=vc_id_student and id_przedmiot=vn_id_przedmiot;
        DBMS_OUTPUT.PUT_LINE('Student o id ' || vn_id_student || ' zdal juz egzamin z przedmiotu o id ' || vn_id_przedmiot);
        exception
            when no_data_found then
                insert into egzaminy values(vn_id_egzamin, vc_id_student, vn_id_przedmiot, vc_id_egzaminator, vd_data_egzamin, vn_id_osrodek, vc_zdal, vn_punkty);
                
    end;
     
    Task 216.
    Kod pomocniczy 1:
    declare
        vCourseNum number ; 
        vLastDay date ;
        cursor c1 is select id_student, count(distinct id_przedmiot) FinCourses
                    from egzaminy
                    where zdal = 'T'
                    group by id_student;
                    
    begin
        select count(*) into vCourseNum from przedmioty ;
        for vc1 in c1 loop
            if vCourseNum = vc1.FinCourses + 1 then
                select max(data_egzamin) into vLastDay 
                    from egzaminy where id_student = vc1.id_student and zdal = 'T' ;
                update studenci s set nr_ecdl = id_student, data_ecdl = vLastDay
                        where s.id_student = vc1.id_student ;
            end if ; 
        end loop ;
    end ; 
     
    ADRIAN JEDYNAK:
    declare
        cyfra1 number;
        cyfra2 number;
        wyjatek exception;
        
        cursor dane_studenta is select id_student, nazwisko, imie from studenci where nr_ecdl is not null or data_ecdl is not null;
    begin
        select count(*) into cyfra1 from przedmioty;
        for vc1 in dane_studenta loop
        
        begin
            select count(distinct id_przedmiot) into cyfra2 from egzaminy where id_student = vc1.id_student and zdal = 'T';
            if cyfra1 != cyfra2 then raise wyjatek;
            end if;
        exception
            when wyjatek then
                dbms_output.put_line(vc1.id_student || ' ' || vc1.nazwisko || ' ' || vc1.imie);
            end;
        end loop;
    end;
     
     
    Alternatywne rozwiązanie:
    DECLARE
        vCourseCountFin NUMBER;
        vCourseCount NUMBER;
        LastDay DATE;
    BEGIN
    		SELECT COUNT(id_przedmiot) INTO vCourseCount
            FROM przedmioty;
        FOR vc1 IN (SELECT Id_student, Nr_ECDL, Data_ECDL FROM studenci 
                            WHERE Nr_ECDL IS NOT NULL OR Data_ECDL IS NOT NULL) LOOP
        BEGIN
            SELECT MAX(DATA_EGZAMIN) INTO LastDay FROM egzaminy e 
                    WHERE e.id_student = vc1.id_student and zdal = 'T' ;
            SELECT COUNT(distinct id_przedmiot) INTO vCourseCountFin
                FROM egzaminy WHERE Id_student = vc1.Id_student AND Zdal='T';
            IF vCourseCountFin != vCourseCount  THEN
                RAISE_APPLICATION_ERROR(-20002,'Student ' || vc1.Id_student || ' nie zdał jeszcze wszystkich przedmiotow, a mimo to są podane Nr_ECDL lub Data_ECDL.');
            END IF;
            IF vc1.Data_ECDL != LastDay  THEN
                RAISE_APPLICATION_ERROR(-20002,'Student ' || vc1.Id_student || ' ma niepoprawna date w polu Data_ECDL');
            END IF;
            EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM) ; 
        END ;
        END LOOP;
    END;
     
    Task 265:
    DECLARE
        vTemp number ;     
        FUNCTION LiczbaPunktow(studentId NUMBER) RETURN NUMBER IS
            suma NUMBER;
            BEGIN
                SELECT SUM(punkty) INTO suma
                FROM egzaminy e 
                WHERE e.id_student = studentId;
                RETURN suma;
            END LiczbaPunktow;   
    BEGIN
       for vc1 in (SELECT id_student FROM studenci) LOOP
            begin
            	SELECT distinct 1 INTO vTemp from egzaminy e where e.id_student = vc1.id_student ; 
                dbms_output.put_line('Student '|| vc1.id_student  || ' zdobył ' || LiczbaPunktow(vc1.id_student)  || ' punktów');
            exception
               	when no_data_found then 
                      		 dbms_output.put_line('Student '|| vc1.id_student  || ' jeszcze nie zdawał egzaminów');
            end ; 
        end loop;
    END;
     
    Alternatywna wersja:
    DECLARE
        vTemp number ;    
        vPoints number ;
        FUNCTION LiczbaPunktow(studentId NUMBER) RETURN NUMBER IS
            suma NUMBER;
            BEGIN
                SELECT SUM(punkty) INTO suma
                FROM egzaminy e 
                WHERE e.id_student = studentId;
                RETURN suma;
            END LiczbaPunktow;   
    BEGIN
       for vc1 in (SELECT id_student FROM studenci) LOOP
            vPoints := LiczbaPunktow(vc1.id_student) ;
            if vPoints is not null then 
                dbms_output.put_line('Student '|| vc1.id_student  || ' zdobył ' || vPoints  || ' punktów');
            else 
               	dbms_output.put_line('Student '|| vc1.id_student  || ' jeszcze nie zdawał egzaminów');
            end if; 
        end loop;
    END;
    
=================== 17.03.2024 ================================
--Task 268 PRZEMYSLAW MROCZEK

DECLARE
    data_egz date;

    FUNCTION Czy_zdal_wszystko(StudentId VARCHAR2) RETURN BOOLEAN IS
        zdane_przedmioty int;
        przedmioty_do_zdania int;        
    BEGIN
        SELECT COUNT(DISTINCT e.id_przedmiot) INTO zdane_przedmioty FROM egzaminy e WHERE e.id_student = StudentId AND e.zdal='T';
        SELECT COUNT(1) INTO przedmioty_do_zdania FROM PRZEDMIOTY ;
        IF zdane_przedmioty = przedmioty_do_zdania THEN
            RETURN TRUE;
        END IF;          
        RETURN FALSE;          
    END Czy_zdal_wszystko;
    
    FUNCTION ostatni_egzamin(StudentId VARCHAR2) RETURN DATE IS
        data_egz DATE;
    BEGIN
        SELECT max(e.data_egzamin) INTO data_egz FROM egzaminy e where e.id_student = StudentId AND e.zdal='T';
        RETURN data_egz;
    END;
    
    
    
   
BEGIN    
    FOR s IN (SELECT * FROM studenci) LOOP
    
        IF Czy_zdal_wszystko(s.id_student) = TRUE THEN
             data_egz := ostatni_egzamin(s.id_student);
             UPDATE studenci su SET nr_ecdl = s.id_student, data_ecdl=data_egz WHERE su.id_student = s.id_student ;
        END IF;                
    END LOOP;    

END;
    

-- Krzysztof Matyjaszczyk
create table st_dateinvalid as select ID_STUDENT, NAZWISKO, IMIE from STUDENCI where 1=0;


--TASK 274 PRZEMYSLAW MROCZEK 
CREATE OR REPLACE FUNCTION sprawdz_ecdl(StudentId VARCHAR, ecdl_data DATE) RETURN BOOLEAN IS


    FUNCTION Czy_zdal_wszystko(StudentId VARCHAR2) RETURN BOOLEAN IS
        zdane_przedmioty int;
        przedmioty_do_zdania int;        
    BEGIN
        SELECT COUNT(DISTINCT e.id_przedmiot) INTO zdane_przedmioty FROM egzaminy e WHERE e.id_student = StudentId AND e.zdal='T';
        SELECT COUNT(1) INTO przedmioty_do_zdania FROM PRZEDMIOTY ;
        IF zdane_przedmioty = przedmioty_do_zdania THEN
            RETURN TRUE;
        END IF;          
        RETURN FALSE;          
    END Czy_zdal_wszystko;
    
    FUNCTION ostatni_egzamin(data_ecdl DATE) RETURN BOOLEAN IS
        ostatni_data_egz DATE;
    BEGIN
        SELECT max(e.data_egzamin) INTO ostatni_data_egz FROM egzaminy e where e.id_student = StudentId AND e.zdal='T';
        RETURN  data_ecdl > ostatni_data_egz;
    END;
    
BEGIN         
        RETURN Czy_zdal_wszystko(StudentId) AND ostatni_egzamin(ecdl_data);
END sprawdz_ecdl;


-- NOWE OKNO
DECLARE

BEGIN 
    FOR stud IN (SELECT * FROM STUDENCI s WHERE s.data_ecdl IS NOT NULL) LOOP
            IF NOT sprawdz_ecdl(stud.id_student, stud.data_ecdl) THEN
                INSERT INTO ST_DATEINVALID(ID_STUDENT,IMIE,NAZWISKO) VALUES (stud.id_student, stud.imie, stud.nazwisko);              
            END IF;    
    END LOOP;
END;

Zadanie zbliżone do 276
CREATE OR REPLACE TRIGGER ExamsCheckBeforeInsert
    BEFORE INSERT ON Egzaminy 
    FOR EACH ROW
BEGIN
    declare
        vx number ; 
    begin
    if :new.zdal = 'T' then
        select distinct 1 into vx from egzaminy where :new.id_student = id_student
            and :new.id_przedmiot = id_przedmiot and :new.zdal = zdal ;
            raise_application_error(-20000, 'Exam already passed') ;
    end if ; 
    exception
        when no_data_found then
            null;
    end ; 
END ; 
/
declare
    myex exception;
    pragma exception_init(myex, -20000) ; 
begin
    insert into egzaminy values (4000, '0000001', 1, '0004', to_date('17-03-2024', 'dd-mm-yyyy'), 1, 'T', 4) ; 
exception
    when myex then 
        rollback ; 
end ; 

====================== Lab 24-03-2024 ================================
Task A1.
Zbudować kolekcję, której element będzie zawierał dane o numerze roku, liczbie egzaminów w danym roku oraz liczbie egzaminowanych studentów w danym roku.
Następnie wyświetlić wartości znajdujące się w poszczególnych elementach kolekcji.


declare
	type tRecYear is record (year number, 
    						ExamsNumber number,
    						StudentsNumber number) ;
	type tColYears is table of tRecYear ;
	ColYears tColYears := tColYears() ;
	cursor c1 is select extract(year from data_egzamin) YearNum, count(*) ExamsNum, count(distinct id_student) StudNum
        			from egzaminy group by extract(year from data_egzamin) order by 1 desc ;
	i number := 1 ;
begin
    dbms_output.put_line('Creating collection') ;
	for vc1 in c1 loop
		ColYears.extend ;
		ColYears(i) := tColYears(vc1.YearNum, vc1.ExamsNum, vc1.StudNum) ;
		i := i+1 ;
    end loop ;
	dbms_output.put_line('Collection created') ;
	for j in ColYears.first..ColYears.last loop
		dbms_output.put_line(ColYears(j).year || ' - ' || ColYears(j).ExamsNumber || ' - ' || ColYears(j).StudentsNumber) ; 
    end loop ;
end ;

Task A2:
Utworzyć kolekcję, której element będzie zawierał dane o numerze roku oraz liczbie egzaminów i liczbie studentów egzaminowanych 
w poszczególnych miesiącach danego roku (miesiąc przedstawić jako numer). Informacje o miesiącach i w/w liczbach należy umieścić w kolekcji.
Następnie należy wyświetlić dane zapisane w kolekcji lat.

1. Definicja typu rekordowego tRecMonth (MonthNumber, #Exams, #Student)
2. Definicja typu kolekcji tColMonths (zbiór miesięcy wraz z w/w liczbami)
3. Definicja typu rekordowego tRecYear (Year, kolekcja miesięcy)
4. Definicja typu kolekcji tColYears (lata, kolekcja miesięcy dla każdego roku)

declare

	type tRecMonth is record (month varchar2(15), 
    						ExamsNumber number,
    						StudentsNumber number) ;
                            
                            
  type tColMonths is table of tRecMonth ;
	ColMonths tColMonths:= tColMonths() ;
	type tRecYear is record (year number, 
    						MonthCol tColMonths) ;
	type tColYears is table of tRecYear ;
	ColYears tColYears := tColYears() ;
  
  cursor getYears is select distinct extract(year from e.data_egzamin) from egzaminy e order by 1 desc;

  cursor c2(year number) is select MonthName, ExamsNum, StudNum from (
  												select to_char(data_egzamin, 'month') MonthName, extract(month from e.data_egzamin) MonthNum, count(*) ExamsNum, 
                          count(distinct id_student) StudNum
													from egzaminy e where year = extract(year from e.data_egzamin)
                          group by to_char(data_egzamin, 'month'), extract(month from e.data_egzamin)
    											) order by MonthNum ;
  
	
begin
    dbms_output.put_line('Creating collection') ;
		
end ;


declare

    type tRecMonth is record (month varchar2(15), 
                        ExamsNumber number,
                        StudentsNumber number) ;
                        
                        
    type tColMonths is table of tRecMonth ;
    ColMonths tColMonths:= tColMonths() ;
    type tRecYear is record (year number, 
                        MonthCol tColMonths) ;
    type tColYears is table of tRecYear ;
    ColYears tColYears := tColYears() ;
    
    cursor getYears is select distinct extract(year from e.data_egzamin) as year_num from egzaminy e order by 1 desc;
    
    cursor getMonthsFromYear(year number) is select MonthName, ExamsNum, StudNum from (
                                            select to_char(data_egzamin, 'month') MonthName, extract(month from e.data_egzamin) MonthNum, count(*) ExamsNum, 
                      count(distinct id_student) StudNum
                                                from egzaminy e where year = extract(year from e.data_egzamin)
                      group by to_char(data_egzamin, 'month'), extract(month from e.data_egzamin)
                                            ) order by MonthNum ;
  i number := 1;
  y number := 1;
	
begin
    dbms_output.put_line('Creating collection') ;
    
    for vyear in getYears loop
        ColYears.extend;
        y  := 1;
        ColMonths := tColMonths() ;
        for vmonth in getMonthsFromYear(vyear.year_num) loop
            
            ColMonths.extend;
            ColMonths(y) := tRecMonth(vmonth.MonthName, vmonth.ExamsNum, vmonth.StudNum);
            y := y + 1;
            
        end loop;
        
        ColYears(i) := tRecYear(vyear.year_num, ColMonths);
        i := i + 1;
    end loop;
    
    for i in 1..ColYears.count() loop
        dbms_output.put_line(ColYears(i).year) ;
        for y in 1..ColYears(i).MonthCol.count() loop
            dbms_output.put_line(ColYears(i).MonthCol(y).month || ' Exam num: ' || ColYears(i).MonthCol(y).ExamsNumber || ' Students num: ' || ColYears(i).MonthCol(y).StudentsNumber) ;
        end loop;

    end loop;
    
end ;

Task 232
PM:
declare
	type tRecPrzedmiot is record (nazwa VARCHAR2(100), 
        data DATE) ;
	type tColPrzedmioty is table of tRecPrzedmiot ;
    type tRecStudent is record (id varchar2(7), 
        nazwisko VARCHAR2(25),
        imie VARCHAR(15),
        przedmioty tColPrzedmioty) ;
    type tColStudents is table of tRecStudent;

	Indeks tColStudents := tColStudents() ;
    ColPrzedmioty tColPrzedmioty := tColPrzedmioty();
    cursor c1 is select distinct id_student IdStudent, nazwisko, imie
                from studenci order by 1 desc ;
    cursor c2(IdStudent VARCHAR2) is select distinct p.nazwa_przedmiot Nazwa, e.data_egzamin DataE
        			from egzaminy e  INNER JOIN przedmioty p on e.id_przedmiot = p.id_przedmiot where e.id_student = IdStudent AND e.zdal='T' order by 1 desc ;
	i number := 1;
    j number := 1;
begin
    dbms_output.put_line('Creating collection') ;
		for vc1 in c1 loop
        ColPrzedmioty := tColPrzedmioty();
        j := 1;
        for vc2 in c2(vc1.IdStudent) loop
            ColPrzedmioty.extend;
            ColPrzedmioty(j) := tRecPrzedmiot(vc2.nazwa, vc2.dataE);
            j := j +1;
        end loop;
        Indeks.extend ;
		Indeks(i) := tRecStudent(vc1.IdStudent, vc1.nazwisko, vc1.imie, ColPrzedmioty) ;
		i := i+1 ;
    end loop ;
	dbms_output.put_line('Collection created') ;
	for k in Indeks.first..Indeks.last loop
		dbms_output.put_line(Indeks(k).imie || ' ' || Indeks(k).nazwisko || ' ' || Indeks(k).id || ':') ; 
        if Indeks(k).przedmioty.count() = 0 then
            	null ;
        else
					for l in Indeks(k).przedmioty.first..Indeks(k).przedmioty.last loop
            	dbms_output.put_line(Indeks(k).przedmioty(l).nazwa || ' - ' || Indeks(k).przedmioty(l).data) ; 
                null;
          end loop;
		end if ; 
    end loop ;
end ;


-- 232 Krzysztof Matyjaszczyk:
declare
    type tzdany_przedmiot is record (
        nazwa przedmioty.nazwa_przedmiot%type,
        data_zdania date
    );
    type tzdane_przedmioty is table of tzdany_przedmiot;
    type tindeks is record (
        id studenci.id_student%type,
        nazwisko studenci.nazwisko%type,
        imie studenci.imie%type,
        zdane_przedmioty tzdane_przedmioty
    );
    type tindeksy is table of tindeks;
    --
    zdane_przedmioty tzdane_przedmioty;
    indeksy tindeksy := tindeksy();
    i number := 1;
    j number;
begin
    for vc_student in (
        select ID_STUDENT, NAZWISKO, IMIE from STUDENCI
    ) loop
        zdane_przedmioty := tzdane_przedmioty();
        j := 1;
        for vc_zdany_przedmiot in (
            select e.DATA_EGZAMIN, p.NAZWA_PRZEDMIOT
            from EGZAMINY e
            inner join PRZEDMIOTY p on p.ID_PRZEDMIOT = e.ID_PRZEDMIOT
            where e.ID_STUDENT = vc_student.ID_STUDENT
            and ZDAL = 'T'
        ) loop
            zdane_przedmioty.extend;
            zdane_przedmioty(j) := tzdany_przedmiot(vc_zdany_przedmiot.NAZWA_PRZEDMIOT, vc_zdany_przedmiot.DATA_EGZAMIN);
            j := j + 1;
        end loop;
        --
        indeksy.extend;
        indeksy(i) := tindeks(vc_student.ID_STUDENT, vc_student.NAZWISKO, vc_student.IMIE, zdane_przedmioty);
        i := i + 1;
    end loop;
    --
    for student_index in indeksy.first .. indeksy.last loop
        DBMS_OUTPUT.PUT_LINE('Student ' || indeksy(student_index).id || ' ' || indeksy(student_index).nazwisko || ' ' || indeksy(student_index).imie);
        for przedmiot_index in indeksy(student_index).zdane_przedmioty.first .. indeksy(student_index).zdane_przedmioty.last loop
            DBMS_OUTPUT.PUT_LINE(
                'Zdany przedmiot: ' || indeksy(przedmiot_index).zdane_przedmioty(przedmiot_index).nazwa
                    || ', Data zdania: ' || to_char(indeksy(student_index).zdane_przedmioty(przedmiot_index).data_zdania, 'YYYY-MM-DD')
            );
        end loop;
    end loop;
end;

INSERT INTO STUDENCI (ID_STUDENT, NAZWISKO, IMIE)
		VALUES ('8888888','Muryjas','Piotr'); 
    
insert into egzaminy values ()    
    
    
    
-- 232 Mroczek Przemyslaw
declare

    type tRecPrzedmiot is record(przedmiot przedmioty.nazwa_przedmiot%TYPE, 
                                data_zdania egzaminy.data_egzamin%TYPE);    

    type tColPrzedmioty is table of tRecPrzedmiot;
    
    type tRecStudent is record (id studenci.id_student%TYPE, 
                        Nazwisko studenci.nazwisko%TYPE,
                        Imie studenci.imie%TYPE,
                        ColPrzedmiot tColPrzedmioty
                        ) ;
    
    type tColIndex is table of tRecStudent;       
    
    ColIndex tColIndex:= tColIndex() ;
    
    
    cursor getStudenci is select ID_STUDENT, IMIE, NAZWISKO from STUDENCI;
        
        
    function uzupelnijPrzedmioty(idStudent number) return tColPrzedmioty IS
    ColPrzedmioty tColPrzedmioty := tColPrzedmioty();
    i number := 1;
    
    cursor getStudenci is select p.nazwa_przedmiot przedmiot, e.data_egzamin data_z from egzaminy e 
    INNER JOIN przedmioty p on p.id_przedmiot=e.id_przedmiot
    WHERE e.id_student=idStudent and e.zdal='T';
    
    BEGIN
        
        for value in getStudenci loop
            ColPrzedmioty.extend;
            ColPrzedmioty(i) := tRecPrzedmiot(value.przedmiot, value.data_z);
        
            i := i + 1;
        end loop;
       
       return ColPrzedmioty;
    END;  
    
    
begin

    for value in getStudenci loop
        ColIndex.extend;
        ColIndex(ColIndex.count()) := tRecStudent(value.ID_STUDENT,value.nazwisko, value.imie, uzupelnijPrzedmioty(value.ID_STUDENT));
  
    end loop;
    
    for i in 1..ColIndex.count() loop
    	dbms_output.put_line(ColIndex(i).nazwisko);
        for j in 1..ColIndex(i).ColPrzedmiot.count() loop
            dbms_output.put_line(ColIndex(i).ColPrzedmiot(j).przedmiot || ' - ' || ColIndex(i).ColPrzedmiot(j).data_zdania);
           
        end loop;
     dbms_output.put_line('---');
    end loop;
    
end ;


