-- Plato configuration
local accountId = 43191; -- Plato account id [IMPORTANT]
local allowPassThrough = false; -- Allow user through if error occurs, may reduce security
local allowKeyRedeeming = false; -- Automatically check keys to redeem if valid
local useDataModel = false;
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()



-------Keysys UI-----------

-- Create a new Fluent window
local window = Fluent.Window:Create({
    Title = "Key Verification",
    Size = UDim2.new(0, 400, 0, 200)
    })
    
    -- Create a text box
    local textBox = Fluent.TextBox:new({
    Parent = window,
    PlaceholderText = "Check Key",
    Size = UDim2.new(0, 300, 0, 30),
    Position = UDim2.new(0, 50, 0, 50)
    })
    
    -- Create a button 1
    local button1 = Fluent.Button:new({
    Parent = window,
    Text = "Button 1",
    Size = UDim2.new(0, 100, 0, 30),
    Position = UDim2.new(0, 50, 0, 90)
    })
    
    button1.OnClick:Connect(function(getLink)
    print("Key Link Copied")
    end)
    
    -- Create a button 2
    local button2 = Fluent.Button:new({
    Parent = window,
    Text = "Check Key",
    Size = UDim2.new(0, 100, 0, 30),
    Position = UDim2.new(0, 170, 0, 90)
    })
    
    button2.OnClick:Connect(function(verify)
    print("Button 2 clicked!")
    end)
    
    -- Show the window
    window:Show()


-- Plato callbacks
local onMessage = function(message)
    --logic
end;

-- Plato internals [START]
local fRequest, fStringFormat, fSpawn, fWait = request or http.request or http_request or syn.request, string.format, task.spawn, task.wait;
local localPlayerId = game:GetService("Players").LocalPlayer.UserId;
local rateLimit, rateLimitCountdown, errorWait = false, 0, false;
-- Plato internals [END]

-- Plato global functions [START]
function getLink()
    return fStringFormat("https://gateway.platoboost.com/a/%i?id=%i", accountId, localPlayerId);
end;

function verify(key)
    if errorWait or rateLimit then 
        return false;
    end;

    onMessage("Checking key...");

    if (useDataModel) then
        local status, result = pcall(function() 
            return game:HttpGetAsync(fStringFormat("https://api-gateway.platoboost.com/v1/public/whitelist/%i/%i?key=%s", accountId, localPlayerId, key));
        end);
        
        if status then
            if string.find(result, "true") then
                onMessage("Successfully whitelisted!");
                return true;
            elseif string.find(result, "false") then
                if allowKeyRedeeming then
                    local status1, result1 = pcall(function()
                        return game:HttpPostAsync(fStringFormat("https://api-gateway.platoboost.com/v1/authenticators/redeem/%i/%i/%s", accountId, localPlayerId, key), {});
                    end);

                    if status1 then
                        if string.find(result1, "true") then
                            onMessage("Successfully redeemed key!");
                            return true;
                        end;
                    end;
                end;
                
                onMessage("Key is invalid!");
                return false;
            else
                return false;
            end;
        else
            onMessage("An error occured while contacting the server!");
            return allowPassThrough;
        end;
    else
        local status, result = pcall(function() 
            return fRequest({
                Url = fStringFormat("https://api-gateway.platoboost.com/v1/public/whitelist/%i/%i?key=%s", accountId, localPlayerId, key),
                Method = "GET"
            });
        end);

        if status then
            if result.StatusCode == 200 then
                if string.find(result.Body, "true") then
                    onMessage("Successfully whitelisted key!");
                    return true;
                else
                    if (allowKeyRedeeming) then
                        local status1, result1 = pcall(function() 
                            return fRequest({
                                Url = fStringFormat("https://api-gateway.platoboost.com/v1/authenticators/redeem/%i/%i/%s", accountId, localPlayerId, key),
                                Method = "POST"
                            });
                        end);

                        if status1 then
                            if result1.StatusCode == 200 then
                                if string.find(result1.Body, "true") then
                                    onMessage("Successfully redeemed key!");
                                    return true;
                                end;
                            end;
                        end;
                    end;
                    
                    return false;
                end;
            elseif result.StatusCode == 204 then
                onMessage("Account wasn't found, check accountId");
                return false;
            elseif result.StatusCode == 429 then
                if not rateLimit then 
                    rateLimit = true;
                    rateLimitCountdown = 10;
                    fSpawn(function() 
                        while rateLimit do
                            onMessage(fStringFormat("You are being rate-limited, please slow down. Try again in %i second(s).", rateLimitCountdown));
                            fWait(1);
                            rateLimitCountdown = rateLimitCountdown - 1;
                            if rateLimitCountdown < 0 then
                                rateLimit = false;
                                rateLimitCountdown = 0;
                                onMessage("Rate limit is over, please try again.");
                            end;
                        end;
                    end); 
                end;
            else
                return allowPassThrough;
            end;    
        else
            return allowPassThrough;
        end;
    end;
end;
-- Plato global functions [END]