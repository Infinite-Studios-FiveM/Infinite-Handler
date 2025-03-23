Infinite = Infinite or {};
Infinite.Config = Infinite.Config or {};

exports('SetDeveloperMode', function(state)
    Infinite.Config.DevelopmentMode = state;
end);

exports('IsDeveloperMode', function()
    return Infinite.Config.DevelopmentMode;
end);