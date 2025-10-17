# Script PowerShell pour interagir avec l'API xAI Grok
# Inspiré par @Grok - Utilise Invoke-RestMethod pour simplicité
# Prérequis : Obtiens ton API key sur https://x.ai/api et définis-le comme variable d'environnement XAI_API_KEY

# Déclaration des variables
$ApiKey = $env:XAI_API_KEY  # Ou hardcode pour test : $ApiKey = "ton_api_key_ici"
$ApiUrl = "https://api.x.ai/v1/chat/completions"  # Endpoint principal
$Model = "grok-beta"  # Ou "grok-2" si disponible pour toi
$Prompt = "Explique-moi en français comment automatiser une tâche admin sys avec PowerShell."  # Change ça pour ton query
$MaxTokens = 500  # Limite de tokens de sortie
$Temperature = 0.7  # Créativité (0-1)

# Vérification de l'API key
if (-not $ApiKey) {
    Write-Error "Erreur : Variable d'environnement XAI_API_KEY non définie. Va sur https://x.ai/api pour en obtenir une."
    exit 1
}

# Corps de la requête JSON
$Body = @{
    model = $Model
    messages = @(
        @{
            role = "user"
            content = $Prompt
        }
    )
    max_tokens = $MaxTokens
    temperature = $Temperature
} | ConvertTo-Json -Depth 3

# Headers pour l'auth
$Headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}

try {
    # Envoi de la requête
    $Response = Invoke-RestMethod -Uri $ApiUrl -Method Post -Body $Body -Headers $Headers
    
    # Extraction de la réponse
    $GrokResponse = $Response.choices[0].message.content
    $Usage = $Response.usage  # Tokens utilisés (input + output)
    
    # Affichage
    Write-Host "Réponse de Grok :" -ForegroundColor Green
    Write-Host $GrokResponse
    Write-Host "`nUsage : Input tokens = $($Usage.prompt_tokens), Output tokens = $($Usage.completion_tokens)" -ForegroundColor Yellow
}
catch {
    Write-Error "Erreur lors de l'appel API : $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $StreamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $ErrorResponse = $StreamReader.ReadToEnd()
        Write-Host "Détails erreur : $ErrorResponse" -ForegroundColor Red
    }
}

# Fin du script
Write-Host "Script terminé. Pour plus d'infos sur l'API : https://x.ai/api" -ForegroundColor Cyan
