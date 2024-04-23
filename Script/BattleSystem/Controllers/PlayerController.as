class ABattlePlayerControllerBase : APlayerController
{
    UPROPERTY(Category = "Input")
    UInputAction Action;

    UPROPERTY(Category = "Input")
    UInputMappingContext Context;

    UPROPERTY(DefaultComponent)
    UEnhancedInputComponent InputComponent;

    ABattleGameModeBase BattleGameMode;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        PushInputComponent(InputComponent);

        UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(this);
        EnhancedInputSubsystem.AddMappingContext(Context, 0, FModifyContextOptions());

        BattleGameMode = Cast<ABattleGameModeBase>(Gameplay::GetGameMode());
        InputComponent.BindAction(Action, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"NextTurnInput"));

    }

    UFUNCTION()
    void PlayerUseSkill(FSkill Skill) {
        if (BattleGameMode == nullptr) return;
        AUnitBase CurrentCharacter = BattleGameMode.CurrentUnit;
        if (CurrentCharacter == nullptr) return;
        if (CurrentCharacter.Character.IsPlayerCharacter)
        {
            APlayerUnitBase PlayerUnit = Cast<APlayerUnitBase>(CurrentCharacter);
            if (PlayerUnit != nullptr && BattleGameMode.EnemyTurnOrder.Num() > 0) {
                AUnitBase Target = BattleGameMode.EnemyTurnOrder[0];
                if (Target != nullptr) {
                    PlayerUnit.CombatComponent.UseSkill(Skill, Target);
                }
            }
        }
        BattleGameMode.ReadyNextTurn();
    }

    UFUNCTION()
    void NextTurnInput(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, UInputAction SourceAction)
    {
        if (BattleGameMode == nullptr) return;
        BattleGameMode.ReadyNextTurn();
    }

}