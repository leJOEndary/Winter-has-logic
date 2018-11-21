obstacle(-100,-100).
dragon_stone(-100,-110).

% Importing initial_state
?- multifile player/6, white_walker/4.
?- [knowledgeBase].


mul2(A,R):-
    add(A,A,R).

add(A,B, Result):-
    Result is A + B.





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Successor Axioms                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Pre-conditions (Helpers):-
%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Checks that the cell(X,Y) is available for jon to move to (Has no Obstacles nor  WhiteWalkers)
% X & Y are Jon's potential new Position
can_move_to(X, Y, S):-
    cell(X, Y),
    \+ obstacle(X, Y),
    (   
        (white_walker(X, Y, Hp, S), Hp = 0);
        \+ white_walker(X, Y, _, S)
    ).

% Refills the inventory upon encountering the dragon stone.
% X & Y are Jon's current Position
refill_Inv(X, Y, Max_inv, Old_inv, New_inv):-
    % Either
    (   % Stepped on DragonStone
        dragon_stone(X, Y) ->
        % then Refill inv.
        New_inv = Max_inv
    );

    % Or
    (   % Didn't step on DragonStone
        (\+ dragon_stone(X, Y)) ->
        % Then inv stays the same
        New_inv = Old_inv
    ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We calculate those in order to keep track of how many WW did we kill

ww_in_X(X, Y, WW_Exists, S):-
    (
        (   
            white_walker(X, Y, Hp, S),
            Hp = 1
        ) ->  
        WW_Exists = 1
    );
        
    WW_Exists = 0.


% WW_Exists will be 1 if there's a WW above, else 0
ww_in_the_north(X, Y, WW_Exists, S):-
    PrevX is X - 1,
    ww_in_X(PrevX, Y, WW_Exists, S).

% WW_Exists will be 1 if there's a WW below, else 0
ww_in_the_south(X, Y, WW_Exists, S):-
    PrevX is X + 1,
    ww_in_X(PrevX, Y, WW_Exists, S).

% WW_Exists will be 1 if there's a WW left, else 0
ww_in_the_west(X, Y, WW_Exists, S):-
    PrevY is Y - 1,
    ww_in_X(X, PrevY, WW_Exists, S).

% WW_Exists will be 1 if there's a WW right, else 0
ww_in_the_east(X, Y, WW_Exists, S):-
    PrevY is Y + 1,
    ww_in_X(X, PrevY, WW_Exists, S).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Checks whether attack is a possible move from jon's current X & Y position.
can_attack(X, Y, Inventory, Num_near_ww, S):-
    Inventory > 0,
    ww_in_the_south(X, Y, South, S),
    ww_in_the_east(X, Y, East, S),
    ww_in_the_west(X, Y, West, S),
    ww_in_the_north(X, Y, North, S),
    add(East, West, R1),
    add(R1, North, R2),
    add(R2, South, Num_near_ww).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jon's Axioms :-
%%%%%%%%%%%%%%%%%
player(New_X, New_Y, Max_inv, New_inv, WW_alive_updated, result(A,S)):-

    player(X, Y, Max_inv, Old_inv, WW_alive, S),
    (
        (   
            % Either Attack
            (A=attack,
            New_X = X, 
            New_Y = Y,
            can_attack(X, Y, Old_inv, Num_near_ww, S),
            Num_near_ww > 0,
            New_inv is Old_inv - 1,
            WW_alive_updated is WW_alive - Num_near_ww);
        
            % Or Move
            (   
                    % Up
                (   (A = up, 
                    New_X is X - 1, 
                    New_Y = Y);

                    % Or Down
                    (A = down,
                    New_X is X + 1,
                    New_Y = Y);

                    % Or Left
                    (A = left,
                    New_X = X,
                    New_Y is Y - 1);

                    % Or Right
                    (A = right,
                    New_X = X,
                    New_Y is Y + 1)
                ),
                can_move_to(New_X, New_Y, S),
                refill_Inv(New_X, New_Y, Max_inv, Old_inv, New_inv),
                WW_alive_updated = WW_alive
                
            )
        ),
        cell(New_X,New_Y)
    ).
    


% Checks whether the WhiteWalker in position X & Y is attacked a valid attack (Jon is near & has dragonglass).
jon_near(X, Y, S):-
    North is X - 1,
    South is X + 1,
    East is Y +1,
    West is Y-1,
    (
        player(South, Y, _, _, _, S);
        player(North, Y, _, _, _, S);
        player(X, East, _, _, _, S);
        player(X, West, _, _, _, S)
    ).


% WhiteWalker's Axioms :-
%%%%%%%%%%%%%%%%%%%%%%%%%

% X & Y are Jon's current Position.
white_walker(X, Y, New_Hp, result(A,S)):-
    white_walker(X, Y, Hp, S),
    (   % Either 
        (   
            % Attacked
            (   A = attack, 
                jon_near(X, Y, S)
            ) ->
            % Then Hp = 0
            New_Hp = 0
        );
        % Or 
        (   
            % Not Attacked
            (   \+ A = attack;
                \+ jon_near(X, Y, S)         
            ) ->
            % Then Hp stays the same
            New_Hp = Hp
        )     
    ).




iterative_deepening(X,S):-
    call_with_depth_limit(player(_,_,_,_,0,S), X, _);
    (
        Next_X is X + 1,
        iterative_deepening(Next_X,S)
    ).
       
   
q(X, Y, Max, Cur, S):-
    player(X,Y, Max, Cur, 0, S),
    \+ S = s0,
    \+ Cur = Max.

