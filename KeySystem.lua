-- Plato configuration
local accountId = 43191; -- Plato account id [IMPORTANT]
local allowPassThrough = false; -- Allow user through if error occurs, may reduce security
local allowKeyRedeeming = false; -- Automatically check keys to redeem if valid
local useDataModel = false;
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Create a new Fluent window
local Window = Fluent:CreateWindow({
    Title = "Key Verification",
    SubTitle = "XephyrHub",
    TabWidth = 160,
    Size = UDim2.fromOffset(540, 300),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local KeyInput = Window:CreateInput({
    Title = "Enter Key",
    Parent = Window,
    Placeholder = "Enter your key here...",
    Size = UDim2.fromOffset(400, 50),
    Position = UDim2.fromOffset(70, 50)
})

local VerifyButton = Window:CreateButton({
    Text = "Verify Key",
    Size = UDim2.fromOffset(400, 50),
    Position = UDim2.fromOffset(70, 120),
    BackgroundColor = Color3.fromRGB(0, 170, 0)
})

local StatusLabel = Window:CreateLabel({
    Text = "Status: Waiting for input...",
    Size = UDim2.fromOffset(400, 50),
    Position = UDim2.fromOffset(70, 200),
    TextColor = Color3.fromRGB(255, 255, 255)
})

-- Plato callbacks
local onMessage = function(message)
    StatusLabel.Text = "Status: " .. message
end

-- Event handler for Verify Button
VerifyButton.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    if key == "" then
        onMessage("Please enter a key.")
        return
    end
    
    onMessage("Checking key...")
    
    local isValid = verify(key)
    
    if isValid then
        onMessage("Key is valid!")
    else
        onMessage("Key is invalid or an error occurred.")
    end
end)


-- Plato callbacks
local onMessage = function(message)
    -- logic
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
            onMessage("An error occurred while contacting the server!");
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
