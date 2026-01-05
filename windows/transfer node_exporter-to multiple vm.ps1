# --- Configuration ---
$USERNAME = "kumsa"
$SOURCE_FILE = ".\node_exporter-1.9.1.linux-amd64.tar.gz"
$DESTINATION_PATH = "/tmp/"

# IMPORTANT: Paste the cleaned, unique IP addresses below, each in quotes and separated by a comma.
$TARGET_HOSTS = @(
    "10.1.177.135",
    "10.2.125.27",
    "10.2.125.130",
    "10.1.177.46"
)

# --- Execution Loop ---
$TotalHosts = $TARGET_HOSTS.Count
$SuccessCount = 0
$FailureCount = 0

Write-Host "Starting SCP to $TotalHosts unique hosts..."
Write-Host "Source: $SOURCE_FILE"
Write-Host "User: $USERNAME"
Write-Host "Destination: $DESTINATION_PATH"
Write-Host "---"

foreach ($Server in $TARGET_HOSTS) {
    # <-- CHANGED $HOST to $Server
    Write-Host "Attempting to copy to $Server..."

    # Construct the scp command arguments
    $Command = "scp"
    $Arguments = @(
        $SOURCE_FILE,
        "$USERNAME@$Server`:$DESTINATION_PATH" # <-- CHANGED $HOST to $Server
    )

    # Use the call operator '&' to run the external command
    & $Command $Arguments

    if ($LASTEXITCODE -eq 0) {
        Write-Host " Success on $Server" -ForegroundColor Green
        $SuccessCount++
    }
    else {
        Write-Host " Failed on $Server (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
        $FailureCount++
    }
    Write-Host ""
}