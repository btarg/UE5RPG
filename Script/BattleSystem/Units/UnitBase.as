class AUnitBase : ACharacter
{
    UPROPERTY(DefaultComponent)
    UCombatComponent CombatComponent;

    UPROPERTY(DefaultComponent)
    UInventoryComponent InventoryComponent;

    UPROPERTY()
    FCharacter Character;
    UPROPERTY()
    FName DataTableCharacter;
    UPROPERTY(BlueprintReadOnly)
    FString CurrentDisplayName;
    UPROPERTY(BlueprintReadOnly)
    int32 TurnsLeft;

    UPROPERTY(BlueprintReadOnly)
    FTransform BattlePosition;
    UPROPERTY(BlueprintReadOnly)
    TArray<FStatModifier> StatModifiers;

    UPROPERTY(BlueprintReadWrite)
    int CurrentHP;
    UPROPERTY(BlueprintReadWrite)
    int CurrentSP;

    ABattleGameModeBase BattleGameMode;

    UPROPERTY(BlueprintReadOnly)
    TArray<FAffinity> Affinities;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        CurrentDisplayName = Character.DisplayName;

        BattleGameMode = Cast<ABattleGameModeBase>(Gameplay::GetGameMode());
        if (BattleGameMode == nullptr)
        {
            Print("Null gamemode!");
            return;
        }
        BattleGameMode.AddUnitToBattle(this);
    }

    UFUNCTION()
    FAffinity GetAffinityByDamageType(TSubclassOf<UDamageType> DamageType)
    {
        for (auto Affinity : Affinities) {
            if (Affinity.DamageType == DamageType) {
                return Affinity;
            }
        }
        return FAffinity(); // Return an empty affinity if none is found
    }

    UFUNCTION()
    void TakeDamage(int32 Damage, TSubclassOf<UDamageType> DamageType, AUnitBase Attacker) {
        CurrentHP -= Damage;
        Print(Character.DisplayName + " took " + Damage + " damage from " + Attacker.Character.DisplayName);
        Print("Damage type: " + DamageType.Get());
        if (CurrentHP <= 0)
        {
            CurrentHP = 0;
            if (BattleGameMode != nullptr)
            {
                //TODO: dead
                Print("Unit was killed by " + Attacker.Character.DisplayName);
                BattleGameMode.UnitDied(this);
                return;
            }
        }
    }
    UFUNCTION()
    void Heal(int32 Amount)
    {
        CurrentHP += Amount;
        float MaxHP = GetStat(ECharacterStat::MaxHP);
        if (CurrentHP > MaxHP)
        {
            CurrentHP = MaxHP;
        }
    }

    UFUNCTION(BlueprintCallable, BlueprintEvent)
    void StartUnitTurn()
    {
        if (BattleGameMode != nullptr) {
            BattleGameMode.OnUnitTurnStarted.Broadcast(this);
        }

        // do not start turn if dead
        if (CurrentHP <= 0)
        {
            return;
        }

        // Print("Starting turn: " + Character.DisplayName);
        TArray<FStatModifier> ModifiersToRemove;
        for (FStatModifier& Modifier : StatModifiers)
        {
            // if turn duration is -1 then it is infinite
            if (Modifier.TurnDuration == -1)
            {
                continue;
            }
            Modifier.TurnDuration -= 1;
            if (Modifier.TurnDuration <= 0)
            {
                ModifiersToRemove.Add(Modifier);
            }
        }
        for (FStatModifier& Modifier : ModifiersToRemove)
        {
            RemoveStatModifier(Modifier);
        }
    }
    UFUNCTION(BlueprintCallable, BlueprintEvent)
    void EndUnitTurn()
    {
        TurnsLeft -= 1;
        if (TurnsLeft <= 0)
        {
            if (BattleGameMode != nullptr)
            {
                BattleGameMode.OnUnitTurnEnded.Broadcast(this);
                BattleGameMode.ReadyNextTurn();
            }
        }
    }
    UFUNCTION(BlueprintCallable)
    void BeginBattle()
    {
        // debug modfier doubles max HP
        // AddStatModifierByName(FName("TestMod"));
        CurrentHP = GetStat(ECharacterStat::MaxHP);
        CurrentSP = GetStat(ECharacterStat::MaxSP);
    }

    UFUNCTION(BlueprintCallable)
    bool AddStatModifierByName(FName StatModifierName)
    {
        UObject TableObject = LoadObject(UDataTable::StaticClass(), "/Game/Data/StatModifierTable.StatModifierTable");
        UDataTable StatModifiersDataTable = Cast<UDataTable>(TableObject);
        FStatModifier foundModifier;
        bool found = StatModifiersDataTable.FindRow(StatModifierName, foundModifier);
        if (found)
        {
            AddStatModifier(foundModifier);
        }
        return found;
    }

    UFUNCTION(BlueprintCallable)
    void AddStatModifier(FStatModifier ToAdd)
    {
        Print("Adding stat modifier: " + ToAdd.Name);
        StatModifiers.Add(ToAdd);

    }

    UFUNCTION(BlueprintCallable)
    void RemoveStatModifier(FStatModifier ToRemove)
    {
        StatModifiers.Remove(ToRemove);
        // if current stats are higher than max then set to max
        float MaxHP = GetStat(ECharacterStat::MaxHP);
        float MaxSP = GetStat(ECharacterStat::MaxSP);

        if (CurrentHP > MaxHP)
        {
            CurrentHP = MaxHP;
        }
        if (CurrentSP > MaxSP)
        {
            CurrentSP = MaxSP;
        }
    }

    UFUNCTION(BlueprintCallable)
    float GetStat(ECharacterStat Stat)
    {
        TArray<FCharacterStatEntry> Stats = GetAllStats();
        for (FCharacterStatEntry& StatEntry : Stats)
        {
            if (StatEntry.StatKey == Stat)
            {
                return StatEntry.StatValue;
            }
        }
        return 0;
    }

    TArray<FCharacterStatEntry> GetAllStats()
    {
        TArray<FString> Applied;

        // Apply Stat Modifiers
        TArray<FCharacterStatEntry> Stats = Character.BaseStats.Stats;
        for (FStatModifier& Modifier : StatModifiers)
        {
            Applied.Add(Modifier.Name);
            // Non-stackable modifiers don't get applied if there are more than one
            // but stay in the list in case it is the only one left next turn
            if (Applied.Contains(Modifier.Name))
            {
                if (!Modifier.bCanStack) {
                    continue;
                }
            }

            for (FCharacterStatEntry& StatEntry : Stats)
            {
                // try to get the multiplier from the map but if it doesn't exist then use 1
                float Multiplier = 1;
                if (Modifier.StatMultipliers.Contains(StatEntry.StatKey))
                {
                    Multiplier = Modifier.StatMultipliers[StatEntry.StatKey];
                }
                StatEntry.StatValue *= Multiplier;
            }
        }
        return Stats;
    }
}