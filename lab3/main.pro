﻿% Copyright

implement main
    open core, stdio, file

domains
    pharmacy_name = string.
    инфо_лекарства = инфо_лекарства(string Название_лекарства, real Стоимость, integer Количество).
    инфо_аптеки = инфо_аптеки(string Название_аптеки, string Адрес, string Телефон).

class facts - pharmacy
    аптека : (integer ID_аптеки, pharmacy_name Название_аптеки, string Адрес, string Телефон).
    лекарство : (integer ID_лекарства, string Название_лекарства).
    продает : (integer ID_аптеки, integer ID_лекарства, real Стоимость, integer Количество).

class predicates
    доступные_лекарства : (pharmacy_name Название_аптеки) -> инфо_лекарства* Лекарства determ.
    кол_лекарств : (pharmacy_name Название_аптеки) -> integer N determ.
    аптеки_с_лекарством : (string Лекарство) -> инфо_аптеки* Аптеки determ.
    адрес_аптеки_с_наименьшей_ценой_лекарства : (string Лекарство) -> string* Адрес determ.
    общая_стоимость_лекарств_аптеки : (pharmacy_name Аптека) -> real Стоимость determ.
    адрес_аптеки_где_заданное_лекарство_есть_в_количестве_не_менее_чем_N : (string Лекарство, integer N) -> string* Адрес determ.
    средняя_стоимость : (string Лекарство) -> real Стоимость determ.
    outputmed : (инфо_лекарства* Инфо_лекарства).
    outputpharm : (инфо_аптеки* Инфо_аптеки).
    длина : (A*) -> integer N.
    сумма_элем : (real* List) -> real Sum.
    среднее_списка : (real* List) -> real Average determ.

clauses
    длина([]) = 0.
    длина([_ | T]) = длина(T) + 1.

    сумма_элем([]) = 0.
    сумма_элем([H | T]) = сумма_элем(T) + H.

    среднее_списка(L) = сумма_элем(L) / длина(L) :-
        длина(L) > 0.

clauses
    доступные_лекарства(Название_аптеки) = List1 :-
        аптека(ID_аптеки, Название_аптеки, _, _),
        !,
        List1 =
            [ инфо_лекарства(Лекарство, Стоимость, Количество) ||
                продает(ID_аптеки, ID_лекарства, Стоимость, Количество),
                лекарство(ID_лекарства, Лекарство)
            ].

    кол_лекарств(Название_аптеки) = длина(доступные_лекарства(Название_аптеки)).

    аптеки_с_лекарством(Лекарство) = List2 :-
        лекарство(ID_лекарства, Лекарство),
        !,
        List2 =
            [ инфо_аптеки(Аптека, Телефон, Адрес) ||
                продает(ID_аптеки, ID_лекарства, _, _),
                аптека(ID_аптеки, Аптека, Телефон, Адрес)
            ].

    адрес_аптеки_с_наименьшей_ценой_лекарства(Лекарство) = List3 :-
        лекарство(ID_лекарства, Лекарство),
        !,
        List3 =
            [ Адрес ||
                продает(ID_аптеки, ID_лекарства, Стоимость1, _),
                аптека(ID_аптеки, _, _, Адрес),
                not((продает(_, ID_лекарства, Стоимость2, _) and Стоимость2 < Стоимость1))
            ].

    общая_стоимость_лекарств_аптеки(Аптека) = сумма_элем([ Стоимость * Количество || продает(ID_аптеки, _, Стоимость, Количество) ]) :-
        аптека(ID_аптеки, Аптека, _, _),
        !.

    адрес_аптеки_где_заданное_лекарство_есть_в_количестве_не_менее_чем_N(Лекарство, N) = List4 :-
        лекарство(ID_лекарства, Лекарство),
        !,
        List4 =
            [ Адрес ||
                продает(ID_аптеки, ID_лекарства, _, Количество),
                Количество >= N,
                аптека(ID_аптеки, _, _, Адрес)
            ].

    средняя_стоимость(Лекарство) = среднее_списка([ Стоимость || продает(_, ID_лекарства, Стоимость, _) ]) :-
        лекарство(ID_лекарства, Лекарство),
        !.

    outputmed(L) :-
        foreach инфо_лекарства(Название_лекарства, Стоимость, Количество) = list::getMember_nd(L) do
            writef(string::format("%8s\t%2.2f\t%10d\n", Название_лекарства, Стоимость, Количество))
        end foreach.

    outputpharm(L) :-
        foreach инфо_аптеки(Аптека, Телефон, Адрес) = list::getMember_nd(L) do
            writef("%\t%\t\t%\n", Аптека, Телефон, Адрес)
        end foreach.

clauses
    run() :-
        console::init(),
        reconsult("../pharmacy.txt", pharmacy),
        fail.

    run() :-
        Название_аптеки = "Горздрав",
        writef("\tАссортимент аптеки %s:\n", Название_аптеки),
        writef("%\t%\t%\n", "Лекарство", "Стоимость", "Количество"),
        outputmed(доступные_лекарства(Название_аптеки)),
        writef("\t%\n", "---------------------------"),
        write("\n"),
        write("Количество видов лекарств  =  "),
        write(кол_лекарств(Название_аптеки)),
        write("\n\n"),
        fail.

    run() :-
        Название_лекарства = "Нурофен",
        writef("\t%s находится в следующих аптеках:\n", Название_лекарства),
        writef("%\t\t%\t\t%\n", "Аптека", "Телефон", "Адрес"),
        outputpharm(аптеки_с_лекарством(Название_лекарства)),
        writef("\t%\n", "---------------------------"),
        write("\n"),
        fail.

    run() :-
        Лекарство = "Цитрамон",
        writef("Самый дешевый %s находится в аптеке по адресу: ", Лекарство),
        write(адрес_аптеки_с_наименьшей_ценой_лекарства(Лекарство), "\n\n"),
        fail.

    run() :-
        Название_аптеки = "Столички",
        Стоимость = общая_стоимость_лекарств_аптеки(Название_аптеки),
        writef("Общая стоимость лекарств в аптеке %: %", Название_аптеки, Стоимость),
        write("\n\n"),
        fail.

    run() :-
        Лекарство = "Нурофен",
        N = 11,
        Адрес = адрес_аптеки_где_заданное_лекарство_есть_в_количестве_не_менее_чем_N(Лекарство, N),
        writef("Адрес аптеки, где % есть в количестве не менее, чем %: %", Лекарство, N, Адрес),
        write("\n\n"),
        fail.

    run() :-
        Лекарство = "Кофеин",
        Средняя_стоимость = средняя_стоимость(Лекарство),
        write("Средняя стоимость ", Лекарство, "а: ", Средняя_стоимость),
        write("\n\n"),
        fail.

    run() :-
        succeed.

end implement main

goal
    console::runUtf8(main::run).
