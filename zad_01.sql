-- docker pull gvenzl/oracle-xe:21.3.0 

-- When openning session set this to on
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

--alt version
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


-- Zadanie 192
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
        to_char(vc1.data_egzamin, 'yyyy-mm-dd') || ')');
        for vc2 in c2(vc1.id_przedmiot, vc1.data_egzamin) loop
            dbms_output.put_line(vc2.nazwisko || ' ' || vc2.imie || '(' || vc2.id_student || ')') ; 
        end loop ;
    end loop ; 
end ; 


--Zadanie 195
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


-- Zad. 197
declare
    vpoints number ;
    cursor c1 is select id_egzamin, zdal from egzaminy ;
begin
    for vc1 in c1 loop
        if vc1.zdal = 'N' then
            vpoints := dbms_random.value(2,3) ;
        else
            vpoints := dbms_random.value(3, 5) ;
        end if ;
        update egzaminy e set punkty = vpoints 
                where e.id_egzamin = vc1.id_egzamin ;
    end loop ; 

end ; 

-- Alt
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


--Zadanie 210
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


--Zadanie 211
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
