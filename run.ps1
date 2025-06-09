# Stride Development Runner
# Run this script from PowerShell to build and test the Stride app

Write-Host "🏃‍♂️ Building Stride..." -ForegroundColor Blue

# Build the project
swift build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    
    # Run tests
    Write-Host "🧪 Running tests..." -ForegroundColor Blue
    swift test
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All tests passed!" -ForegroundColor Green
        Write-Host "🎉 Stride is ready to run!" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Some tests failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
}
