class ABattlePosition : AActor
{
    UPROPERTY()
    bool bIsEnemy;
    UPROPERTY()
    bool bHasSpawned;
}

class AArenaSpawner : AActor
{
    UPROPERTY()
    FName EncounterName;
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    TArray<ABattlePosition> BattlePositions;
    FEncounter Encounter;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Spawn();
        ABattleGameModeBase BattleGameMode = Cast<ABattleGameModeBase>(Gameplay::GetGameMode());
       
        if (BattleGameMode != nullptr)
        {
            BattleGameMode.StartBattle(true);
        }
    }

    UFUNCTION()
    void Spawn() {
        // get encounter from data table
        UObject TableObject = LoadObject(UDataTable::StaticClass(), "/Game/Data/EncounterTable.EncounterTable");
        UDataTable EncounterTable = Cast<UDataTable>(TableObject);
        if (EncounterTable == nullptr) {
            return;
        }
        // set encounter by name from encounter table
        bool found = EncounterTable.FindRow(EncounterName, Encounter);
        if (!found) {
            return;
        }
        // get all battle positions
        GetAllActorsOfClass(ABattlePosition::StaticClass(), BattlePositions);
        SpawnEnemies(Encounter.Enemies);

        //TODO: spawn players
        ARPGPlayerStateBase PlayerState = Cast<ARPGPlayerStateBase>(Gameplay::GetPlayerState(0));
        if (PlayerState == nullptr) {
            Print("Null PlayerState");
            return;
        }
        Print("" + PlayerState.Party.Num() + " Players");
        SpawnPlayers(PlayerState.Party);

    }

    void SpawnPlayers(TArray<TSubclassOf<APlayerUnitBase>> Units) {
        for (int i = 0; i < Units.Num(); i++) {
            TSubclassOf<AUnitBase> UnitClass = Units[i];
            SpawnUnit(UnitClass, false);
        }
    }
    void SpawnEnemies(TArray<TSubclassOf<AEnemyUnitBase>> Units) {
        for (int i = 0; i < Units.Num(); i++) {
            TSubclassOf<AUnitBase> UnitClass = Units[i];
            SpawnUnit(UnitClass, true);
        }
    }

    void SpawnUnit(TSubclassOf<AUnitBase> UnitClass, bool bIsEnemy = true) {
        ABattlePosition Position = GetRandomPosition(bIsEnemy);
        if (Position != nullptr) {
            AActor Spawned = SpawnActor(UnitClass, Position.GetActorLocation(), Position.GetActorRotation());
            // AUnitBase Unit = Cast<AUnitBase>(Spawned);
            // if (Unit != nullptr) {
            //     Print("Spawned " + Unit.CurrentDisplayName);
            // } else {
            //     Print("Failed to spawn unit");
            // }
        } else {
            Print("Failed to spawn unit, no available positions");
        }
    }

    ABattlePosition GetRandomPosition(bool bIsEnemy = true) {
        TArray<ABattlePosition> RandomPositions;

        for (int i = 0; i < BattlePositions.Num(); i++) {
            if (!BattlePositions[i].bHasSpawned) {
                if (bIsEnemy == BattlePositions[i].bIsEnemy) {
                    RandomPositions.Add(BattlePositions[i]);
                }
            }
        }
        if (RandomPositions.Num() == 0) {
            return nullptr;
        }
        RandomPositions.Shuffle();
        return RandomPositions[0];
    }
}