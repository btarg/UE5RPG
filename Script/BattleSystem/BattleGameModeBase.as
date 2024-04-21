class ABattleGameModeBase : AGameModeBase
{
    UPROPERTY()
    TArray<AUnitBase> PlayerTurnOrder;
    UPROPERTY()
    TArray<AUnitBase> EnemyTurnOrder;
    
    UPROPERTY()
    TArray<AUnitBase> UnitsInBattle;
    UPROPERTY()
    int32 CurrentTurnIndex;
    UPROPERTY()
    AUnitBase CurrentUnit;
    UPROPERTY()
    bool bIsPlayerTurn;

    UPROPERTY(BlueprintReadOnly)
    bool bCanStartBattle = true;
    UPROPERTY(BlueprintReadOnly)
    bool bIsInBattle = false;

    TMap<FString, int32> CharacterCounts;

    UFUNCTION(BlueprintCallable)
    void AddUnitToBattle(AUnitBase Unit)
    {
        UnitsInBattle.Add(Unit);
        bCanStartBattle = PlayerTurnOrder.IsEmpty() || EnemyTurnOrder.IsEmpty();
    }
    UFUNCTION(BlueprintCallable)
    void RemoveUnitFromBattle(AUnitBase Unit)
    {
        UnitsInBattle.Remove(Unit);
        if (Unit.Character.IsPlayerCharacter)
        {
            PlayerTurnOrder.Remove(Unit);
        }
        else
        {
            EnemyTurnOrder.Remove(Unit);
        }
        bCanStartBattle = PlayerTurnOrder.IsEmpty() || EnemyTurnOrder.IsEmpty();
    }
    UFUNCTION(BlueprintCallable)
    void UnitDied(AUnitBase Unit)
    {
        RemoveUnitFromBattle(Unit);
    }

    UFUNCTION(BlueprintEvent, BlueprintCallable)
    void StartBattle(bool bIsAmbush) {
        if (!bCanStartBattle) return;
        bIsPlayerTurn = bIsAmbush;
        
        TArray<AUnitBase> EnemyUnits;

        CharacterCounts.Empty();
        for (AUnitBase Unit : UnitsInBattle) {
            Unit.BeginBattle();
            if (!Unit.Character.IsPlayerCharacter) {
                EnemyUnits.Add(Unit);
            }
        }
        if (EnemyUnits.Num() > 1) {
            for (AUnitBase Unit : EnemyUnits) {
                FString CharacterName = Unit.Character.DisplayName;
                if (!CharacterCounts.Contains(CharacterName))
                {
                    CharacterCounts.Add(CharacterName, 0);
                }
                int32 Count = CharacterCounts[CharacterName]++;
                Unit.Character.DisplayName = CharacterName + " " + GetLetter(Count);
            }
        }
        
        bIsInBattle = true;        
        CalculateTurnOrder();

        ReadyNextTurn();
    }

    FString GetLetter(int32 Index)
    {
        FString Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        if (Index >= 0 && Index < Alphabet.Len())
        {
            return Alphabet.Mid(Index, 1);
        }
        return "";
    }

    UFUNCTION(BlueprintCallable)
    void EndBattle() {
        Print("Battle has ended.");
        bIsInBattle = false;
        bCanStartBattle = false;
    }

    UFUNCTION(BlueprintCallable)
    void ReadyNextTurn()
    {
        if (PlayerTurnOrder.IsEmpty() || EnemyTurnOrder.IsEmpty() || !bCanStartBattle)
        {
            EndBattle();
            return;
        }

        ESkillResult useSkill = EnemyTurnOrder[0].CombatComponent.UseSkill(n"TestSkill", PlayerTurnOrder[0]);
        Print("Skill result: " + useSkill);


        TArray<AUnitBase> CurrentTurnOrder = bIsPlayerTurn ? PlayerTurnOrder : EnemyTurnOrder;
        if (CurrentTurnOrder.IsValidIndex(CurrentTurnIndex))
        {
            CurrentUnit = CurrentTurnOrder[CurrentTurnIndex];
            CurrentUnit.StartUnitTurn();
            CurrentTurnIndex++;
        }
        else
        {
            // if there are no more units in the turn order
            bIsPlayerTurn = !bIsPlayerTurn; // Switch turn order
            CurrentTurnIndex = 0; // Reset turn index
            TArray<AUnitBase> NextTurnOrder = bIsPlayerTurn ? PlayerTurnOrder : EnemyTurnOrder;
            if (NextTurnOrder.Num() > 0)
            {
                ReadyNextTurn(); // Start the next turn immediately
            }
            else
            {
                if (bIsPlayerTurn) {
                    Print("No players");
                } else {
                    Print("No enemies");
                }
            }
        }
    }

    UFUNCTION(BlueprintCallable)
    void CalculateTurnOrder() {
        PlayerTurnOrder.Empty();
        EnemyTurnOrder.Empty();

        TMap<AUnitBase, int32> PlayerInitiativeRolls;
        TMap<AUnitBase, int32> EnemyInitiativeRolls;
        for (int i = 0; i < UnitsInBattle.Num(); i++)
        {
            int32 InitiativeRoll = Math::RandRange(1, 20) + UnitsInBattle[i].GetStat(ECharacterStat::Vitality);
            if (UnitsInBattle[i].Character.IsPlayerCharacter)
            {
                PlayerInitiativeRolls.Add(UnitsInBattle[i], InitiativeRoll);
            }
            else
            {
                EnemyInitiativeRolls.Add(UnitsInBattle[i], InitiativeRoll);
            }
            Print(UnitsInBattle[i].Character.DisplayName + " rolled " + InitiativeRoll);
        }
        PlayerTurnOrder = CalculateInitiativeOrder(PlayerInitiativeRolls);
        EnemyTurnOrder = CalculateInitiativeOrder(EnemyInitiativeRolls);
    }

    TArray<AUnitBase> CalculateInitiativeOrder(TMap<AUnitBase, int32>& InitiativeRolls)
    {
        TArray<AUnitBase> TurnOrder;
        while(InitiativeRolls.Num() > 0)
        {
            AUnitBase HighestInitiativeUnit;
            int32 HighestInitiative = 0;
            for (auto Pair : InitiativeRolls)
            {
                if (Pair.Value > HighestInitiative)
                {
                    HighestInitiative = Pair.Value;
                    HighestInitiativeUnit = Pair.Key;
                }
            }
            TurnOrder.Add(HighestInitiativeUnit);
            InitiativeRolls.Remove(HighestInitiativeUnit);
        }
        return TurnOrder;
    }
}
