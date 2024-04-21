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
    void NextTurnInput(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, UInputAction SourceAction)
    {
        if (BattleGameMode == nullptr) return;
        BattleGameMode.ReadyNextTurn();
    }

}