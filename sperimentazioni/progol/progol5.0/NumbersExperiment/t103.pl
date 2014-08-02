wordnum(A,[],T) :- tenu(A,[],T).
wordnum(A,[],T) :- word100(A,[],T).
wordnum(A,[],T) :- word1000(A,[],T).
word1000(A,B,T+H) :- thou(A,C,T), word100(C,B,H).
word100(A,[],H) :- hun(A,[],H).
word100(A,B,H+T) :- hun(A,[and|C],H), tenu(C,B,T).
hun([D,hundred|R],R,H*100) :- digit(D,H).
tenu([D],[],N) :- digit(D,N).
tenu([eleven],[],11).
tenu([twelve],[],12).
tenu([thirteen],[],13).
tenu([fourteen],[],14).
tenu([fifteen],[],15).
tenu([nineteen],[],19).
tenu([T],[],N) :- tenmult(T,N).
tenu([T,D],[],N+M) :- tenmult(T,N), digit(D,M).
digit(one,1).
digit(two,2).
digit(three,3).
digit(four,4).
digit(five,5).
digit(six,6).
digit(seven,7).
digit(nine,9).
tenmult(twenty,20).
tenmult(thirty,30).
tenmult(fifty,50).
tenmult(seventy,70).
tenmult(eighty,80).
tenmult(ninety,90).