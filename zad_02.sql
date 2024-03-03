Task 190
set serveroutput on
-- Zad. 190
declare
    cursor c1 is select distinct count(*) ExamNum from egzaminy 
                    group by id_przedmiot
                    order by 1 desc
                    fetch first 3 rows only ;
    cursor c2(pExamNum number) is select nazwa_przedmiot from przedmioty p
                inner join egzaminy e on p.id_przedmiot = e.id_przedmiot
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
