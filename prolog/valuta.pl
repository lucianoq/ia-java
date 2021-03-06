:- module( valuta, [
                      allsimbolo_valuta/1
                    , alltipo_richiesta/1
                    , allvaluta/1
                    , allrichiesta_valuta/1
                    , risrichiesta_valuta/0
                    , tag_richiesta_valuta/0
                   ] 
).

:- use_module(lexer).
:- use_module(kb).

%% Trova tutte le tipologie di richieste
alltipo_richiesta(ListaTipologie) :-
    findall((IDTag, T) ,kb:tag(IDTag, tipo_richiesta(T)), ListaTipologie).

%% Trova tutti i simboli di valuta
allsimbolo_valuta(ListaSimboliValute) :-
    findall((IDTag, S) ,kb:tag(IDTag, simbolo_valuta(S)), ListaSimboliValute).

%% Trova tutte le valute
allvaluta(ListaValute) :-
    findall((IDTag, M, S) ,kb:tag(IDTag, valuta(M,S)), ListaValute).

%% Trova tutte le richieste di valuta
allrichiesta_valuta(ListaRichieste) :-
    findall((IDTag, M, S, T) ,kb:tag(IDTag, richiesta_valuta(M,S,T)), ListaRichieste).

%% Risultati
risrichiesta_valuta :-
    \+kb:vuole(richiesta_valuta), !.
risrichiesta_valuta :-
    allrichiesta_valuta( ListaRichieste ),
    write('Le richieste di valuta trovate sono: '), 
    write( ListaRichieste ).

%% Tagga le richieste di valuta
tag_richiesta_valuta :-
    \+kb:vuole(richiesta_valuta), !.
tag_richiesta_valuta :-
    kb:fatto(richiesta_valuta), !.
tag_richiesta_valuta :-
    tag_valuta,
    tag_tipo_richiesta,
    findall((_,_,_), tag_richiesta_valuta(_,_,_), _),
    kb:assertFact(kb:fatto(richiesta_valuta)).

%% Tagga le valute
tag_valuta :-
    kb:fatto(valuta), !.
tag_valuta :-
    tag_simbolo_valuta,
    base:tag_numero,
    findall((_,_), tag_valuta(_,_), _),
    kb:assertFact(kb:fatto(valuta)).

%% Tagga i simboli di valuta
tag_simbolo_valuta :-
    kb:fatto(simbolo_valuta), !.
tag_simbolo_valuta :-
    findall(_, tag_euro(_), _),
    findall(_, tag_dollaro(_), _),
    kb:assertFact(kb:fatto(simbolo_valuta)).



%% Tagga le tipologie
tag_tipo_richiesta :-
    kb:fatto(tipo_richiesta), !.
tag_tipo_richiesta :-
    findall(_, tag_chirografario(_), _),
    findall(_, tag_totale(_), _),
    findall(_, tag_privilegiato(_), _),
    kb:assertFact(kb:fatto(tipo_richiesta)).

%% Tagga i simboli di valuta
tag_euro(Token) :- 
    euro(Token),
    kb:token(IDToken, Token),
    findall( Precedente, kb:next(Precedente, IDToken), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[SIMBOLO VALUTA] Presenza nel documento del simbolo',Token],' ',Spiegazione),
    kb:appartiene(IDToken, IDDoc),
    assertTag(euro(Token), IDDoc, ListaPrecedenti, ListaSuccessivi,Spiegazione, [IDToken]).

tag_dollaro(Token) :- 
    dollaro(Token),
    kb:token(IDToken, Token),
    findall( Precedente, kb:next(Precedente, IDToken), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[SIMBOLO VALUTA] Presenza nel documento del simbolo',Token],' ',Spiegazione),
    kb:appartiene(IDToken, IDDoc),
    assertTag(dollaro(Token), IDDoc, ListaPrecedenti, ListaSuccessivi,Spiegazione, [IDToken]).


euro('€').
euro('euro').
euro('eur').
dollaro('$').
dollaro('usd').
dollaro('dollar').
dollaro('dollaro').
dollaro('dollari').


%% Tagga le tipologie
tag_chirografario(Tag) :- 
    chiro(Tag),
    kb:tag(IDTag, parola(Tag)),
    findall( Precedente, kb:next(Precedente, IDTag), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[TIPO_RICHIESTA] Presenza nel documento del termine',Tag],' ',Spiegazione),
    kb:appartiene(IDTag, IDDoc),
    assertTag(chiro(Tag), IDDoc, ListaPrecedenti, ListaSuccessivi, Spiegazione, [IDTag]).

%% Tagga le tipologie
tag_privilegiato(Tag) :- 
    privilegiato(Tag),
    kb:tag(IDTag, parola(Tag)),
    findall( Precedente, kb:next(Precedente, IDTag), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[TIPO_RICHIESTA] Presenza nel documento del termine',Tag],' ',Spiegazione),
    kb:appartiene(IDTag, IDDoc),
    assertTag(privilegiato(Tag), IDDoc, ListaPrecedenti, ListaSuccessivi, Spiegazione, [IDTag]).

%% Tagga le tipologie
tag_totale(Tag) :- 
    totale(Tag),
    kb:tag(IDTag, parola(Tag)),
    findall( Precedente, kb:next(Precedente, IDTag), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[TIPO_RICHIESTA] Presenza nel documento del termine',Tag],' ',Spiegazione),
    kb:appartiene(IDTag, IDDoc),
    assertTag(totale(Tag), IDDoc, ListaPrecedenti, ListaSuccessivi, Spiegazione, [IDTag]).

chiro('chirografario').
chiro('chirografaria').
chiro('chirografo').
chiro('chirografa').
chiro('chiro').
chiro('chir').
privilegiato('privilegiato').
privilegiato('privilegiata').
privilegiato('privil').
privilegiato('priv').
totale('totale').
totale('total').
totale('tot').

%% Tagga le valute €
tag_valuta(Moneta, 'euro') :-
    kb:tag(IDTag2, euro(Simbolo)),
    kb:next(IDTag1, IDTag2),    
    kb:tag(IDTag1, numero(_)),
    kb:val(IDTag1,Moneta),
    findall( Precedente, kb:next(Precedente, IDTag1), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag2, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[VALUTA] Presenza nel documento del numero',Moneta,'seguito dal simbolo',Simbolo],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    kb:appartiene(IDTag1, IDDoc),
    kb:appartiene(IDTag2, IDDoc),
    assertTag(valuta(Moneta, 'euro'), IDDoc, ListaPrecedenti, ListaSuccessivi, Spiegazione, Dipendenze).

tag_valuta(Moneta, 'euro') :-
    kb:tag(IDTag2, euro(Simbolo)),
    kb:next(IDTag2, IDTag1),    
    kb:tag(IDTag1, numero(_)),
    kb:val(IDTag1,Moneta),
    findall( Precedente, kb:next(Precedente, IDTag2), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag1, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[VALUTA] Presenza nel documento del numero',Moneta,'preceduto dal simbolo',Simbolo],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    kb:appartiene(IDTag1, IDDoc),
    kb:appartiene(IDTag2, IDDoc),
    assertTag(valuta(Moneta, 'euro'), IDDoc, ListaPrecedenti, ListaSuccessivi, Spiegazione, Dipendenze).

%% Tagga le valute $
tag_valuta(Moneta, 'dollaro') :-
    kb:tag(IDTag2, dollaro(Simbolo)),
    kb:next(IDTag1, IDTag2),    
    kb:tag(IDTag1, numero(_)),
    kb:val(IDTag1,Moneta),
    findall( Precedente, kb:next(Precedente, IDTag1), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag2, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[VALUTA] Presenza nel documento del numero',Moneta,'seguito dal simbolo',Simbolo],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    kb:appartiene(IDTag1, IDDoc),
    kb:appartiene(IDTag2, IDDoc),
    assertTag(valuta(Moneta, 'dollaro'), IDDoc, ListaPrecedenti, ListaSuccessivi, Spiegazione, Dipendenze).

tag_valuta(Moneta, 'dollaro') :-
    kb:tag(IDTag2, dollaro(Simbolo)),
    kb:next(IDTag2, IDTag1),    
    kb:tag(IDTag1, numero(_)),
    kb:val(IDTag1,Moneta),
    findall( Precedente, kb:next(Precedente, IDTag2), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag1, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[VALUTA] Presenza nel documento del numero',Moneta,'preceduto dal simbolo',Simbolo],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    kb:appartiene(IDTag1, IDDoc),
    kb:appartiene(IDTag2, IDDoc),
    assertTag(valuta(Moneta, 'dollaro'), IDDoc, ListaPrecedenti, ListaSuccessivi, Spiegazione, Dipendenze).


%% Tagga le richieste di valuta
tag_richiesta_valuta(Moneta, Simbolo, 'totale') :-
    kb:tag(IDTag1, totale(Totale)),
    kb:tag(IDTag2, valuta(Moneta, Simbolo)),
    kb:appartiene(IDTag1, IDDoc),
    kb:appartiene(IDTag2, IDDoc),
    stessa_frase(IDTag1, IDTag2),
    atomic_list_concat(['[RICHIESTA VALUTA] Presenza nella stessa frase della valuta',Moneta,Simbolo,'e del termine',Totale],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    assertTag(richiesta_valuta(Moneta, Simbolo, 'totale') , IDDoc, Spiegazione, Dipendenze).

tag_richiesta_valuta(Moneta, Simbolo, 'privilegiato') :-
    kb:tag(IDTag1, privilegiato(Priv)),
    kb:tag(IDTag2, valuta(Moneta, Simbolo)),
    kb:appartiene(IDTag1, IDDoc),
    kb:appartiene(IDTag2, IDDoc),
    stessa_frase(IDTag1, IDTag2),
    atomic_list_concat(['[RICHIESTA VALUTA] Presenza nella stessa frase della valuta',Moneta,Simbolo,'e del termine',Priv],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    assertTag(richiesta_valuta(Moneta, Simbolo, 'privilegiato') , IDDoc, Spiegazione, Dipendenze).

tag_richiesta_valuta(Moneta, Simbolo, 'chirografario') :-
    kb:tag(IDTag1, chiro(Chiro)),
    kb:tag(IDTag2, valuta(Moneta, Simbolo)),
    kb:appartiene(IDTag1, IDDoc),
    kb:appartiene(IDTag2, IDDoc),
    stessa_frase(IDTag1, IDTag2),
    atomic_list_concat(['[RICHIESTA VALUTA] Presenza nella stessa frase della valuta',Moneta,Simbolo,'e del termine',Chiro],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    assertTag(richiesta_valuta(Moneta, Simbolo, 'chirografario') ,IDDoc, Spiegazione, Dipendenze).
