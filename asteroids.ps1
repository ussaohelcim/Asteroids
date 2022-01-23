Add-Type -Path '.\engine.dll'

$engine = New-Object engine.Functions 

#$engine.EnableAudioDevice() #need to enable this to be enable to load sounds

$w = 600
$h = 500

$engine.CreateWindow($w, $h, "Esteroids")

$PI = 3.14159
$TAU = $PI * 2

$nave = @{
    shape = $engine.GetNewRectangle2D($w / 2 - 10 ,$h / 2 - 10, 20, 20,$engine.GetNewColor(250,0,0,250))
    rotacao = 0
    velocidade = 0
    linha = $engine.GetNewLine2D($engine.GetNewVector2(0,0),$engine.GetNewVector2(0,0))
    direcao = $engine.GetNewVector2(0,0)
    vivo = $true
}
$maxVel = 200
$corMira = $engine.GetNewColor(254,254,254,254)

[System.Collections.ArrayList]$balas = @()

[System.Collections.ArrayList]$asteroids = @()

[System.Collections.ArrayList]$particulas = @()

$timerSpawnAsteroid = 0.65
$timer = 5
$pontuacao = 0
$spawnPositions = @(
    @{
        pos = $engine.GetNewVector2(-20,-20) #superior esquerdo
        angulos = (0..90)

    },
    @{
        pos = $engine.GetNewVector2($w+20,$h+20) #inferior direito
        angulos = (180..270)
        
    },
    @{
        pos = $engine.GetNewVector2($w+20,-20) #superior direito
        angulos = (90..180)

        
    },
    @{
        pos = $engine.GetNewVector2(0,$h+20) #inferior esquerdo
        angulos = (270..360)


    }
)

$DEG2RAD = $PI / 180
$RAD2DEG = 180 / $PI

while(!$engine.IsAskingToCloseWindow()) {
    
    Start-Sleep -Milliseconds 16

    $timer += $engine.DeltaTime()
    
    if($timer -ge $timerSpawnAsteroid)
    {
        $posSpawn = ($spawnPositions | Get-Random)

        $angulo = (($posSpawn.angulos|Get-Random) / 360) * $TAU

        $pontoDirecao = $engine.AngleToNormalizedVector($angulo)

        $timer = 0
        #$timerSpawnAsteroid -= 0.1

        $tam = ((10..50)|Get-Random)

        $null = $asteroids.Add(@{
            shape = $engine.GetNewRectangle2D($posSpawn.pos.X, $posSpawn.pos.Y, $tam, $tam, $engine.GetNewColor(((30..254)|Get-Random),((30..254)|Get-Random),((30..254)|Get-Random),254))
            direcao = $pontoDirecao * ((3..6)|Get-Random)
            ttl = 2
        })
        
       #Write-Host $angulo ($angulo*$RAD2DEG) $posSpawn.angulos[0] $posSpawn.angulos[$posSpawn.angulos.Length-1]
    }

    $engine.DrawFrame();

    if($nave.vivo)
    {
        $acelerando = $false
        if($engine.IsHoldingKey('w'))
        {
            $acelerando = $true
            $nave.velocidade++
            if($nave.velocidade -ge $maxVel) {$nave.velocidade = $maxVel}
        }
        else {
            $nave.velocidade--
            #Write-Host $nave.velocidade
            if($nave.velocidade -le 0) {$nave.velocidade = 0}
        }
        
        
        if($engine.IsHoldingKey('a'))
        {
            if($nave.rotacao -le 0) {$nave.rotacao = 359}
            $nave.rotacao-=6
        }
        elseif($engine.IsHoldingKey('d'))
        {
            if($nave.rotacao -ge 360 ) {$nave.rotacao = 0}
    
            $nave.rotacao+=6
        }
    
        $angulo = ($nave.rotacao / 360) * $TAU
    
        $pontoDirecao = $engine.AngleToNormalizedVector($angulo)
    
        $centroNave = $engine.GetNewVector2($nave.shape.position.X + $nave.shape.width / 2,$nave.shape.position.Y + $nave.shape.height / 2)
    
        $nave.linha.p1 = $centroNave
        $nave.linha.p2 = $centroNave + $engine.AngleToNormalizedVector($angulo) *30
    
        if($engine.ApertouCima())
        {
            $bala = $engine.GetNewRectangle2D($nave.linha.p2.position.X,$nave.linha.p2.position.Y,5,5,$corMira)
    
            $null = $balas.Add(
                @{
                    bala = $bala
                    direcao = $pontoDirecao * 5
                    ttl = 1
                }
            )
        
        }
        if($acelerando)
        {
            $nave.direcao = $pontoDirecao * $nave.velocidade * $engine.DeltaTime()
        }

        $nave.shape.Move($nave.direcao.X,$nave.direcao.Y)

        if($nave.shape.position.X -lt 0 -and $nave.shape.position.Y -gt 0 )
        {
            $nave.shape.position = $engine.GetNewVector2($w,$nave.shape.position.y)
        }
        elseif($nave.shape.position.X -gt 0 -and $nave.shape.position.Y -gt $h ){
            
            $nave.shape.position = $engine.GetNewVector2($nave.shape.position.x,0)
        }
        elseif($nave.shape.position.X -gt $w -and $nave.shape.position.Y -gt 0 ){
            $nave.shape.position = $engine.GetNewVector2(0,$nave.shape.position.y)

        }
        elseif($nave.shape.position.X -gt 0 -and $nave.shape.position.Y -lt 0 ){
            $nave.shape.position = $engine.GetNewVector2($nave.shape.position.x,$h)
        }

        $nave.linha.Draw($corMira)
        $nave.shape.DrawLines(3,$corMira)
    }

    if($balas.Count -gt 0)
    {
        foreach($b in $balas)
        {
            if($b.ttl -le 0) {$b = $null}

            if(!($null -eq $b))
            {
                if($b.bala.position.X -lt 0 -and $b.bala.position.Y -gt 0 )
                {
                    $b.bala.position = $engine.GetNewVector2($w,$b.bala.position.y)
                }
                elseif($b.bala.position.X -gt 0 -and $b.bala.position.Y -gt $h ){
                    
                    $b.bala.position = $engine.GetNewVector2($b.bala.position.x,0)
                }
                elseif($b.bala.position.X -gt $w -and $b.bala.position.Y -gt 0 ){
                    $b.bala.position = $engine.GetNewVector2(0,$b.bala.position.y)
                }
                elseif($b.bala.position.X -gt 0 -and $b.bala.position.Y -lt 0 ){
                    $b.bala.position = $engine.GetNewVector2($b.bala.position.x,$h)
                }
                $b.ttl -= $engine.DeltaTime()
                $b.bala.Move($b.direcao.X,$b.direcao.Y)
                $b.bala.Draw()

                if($asteroids.Count -gt 0)
                {
                    foreach($asteroid in $asteroids)
                    {
                        if($null -ne $asteroid -and $null -ne $b)
                        {
                            if($b.bala.IsCollidingWithRectangle2D($asteroid.shape)){
                                $null = $particulas.Add(
                                    @{
                                        shape = [engine.Ball2D]::GetNew([int]($asteroid.shape.position.X+$asteroid.shape.width /2),([int]$asteroid.shape.position.Y+$asteroid.shape.height/2),2,254,254,254,50)
                                        ttl = 2
                                    }
                                )
                                $b.ttl = 0
                                $asteroid.ttl = 0
                                $pontuacao++
                            }
                        }
                        
                    }
                }
                
            }   
            
        }

        for ($i = 0; $i -lt $balas.Count; $i++) {
            if($balas[$i].ttl -le 0)
            {
                $balas.RemoveAt($i)
            }
        }
    }
    if($asteroids.Count -gt 0)
    {
        foreach($asteroid in $asteroids)
        {
            if($asteroid.ttl -le 0) {$asteroid = $null }
            if($null -ne $asteroid)
            {
                #Write-Host $asteroid.shape.position
                if($asteroid.shape.position.X -lt 0 -and $asteroid.shape.position.Y -gt 0 )
                {
                    $asteroid.ttl -= $engine.DeltaTime()
                }
                elseif($asteroid.shape.position.X -gt 0 -and $asteroid.shape.position.Y -gt $h ){
                    $asteroid.ttl -= $engine.DeltaTime()
                    
                }
                elseif($asteroid.shape.position.X -gt $w -and $asteroid.shape.position.Y -gt 0 ){
                    $asteroid.ttl -= $engine.DeltaTime()
                }
                elseif($asteroid.shape.position.X -gt 0 -and $asteroid.shape.position.Y -lt 0 ){
                    $asteroid.ttl -= $engine.DeltaTime()
                }
                $asteroid.shape.Move($asteroid.direcao.X,$asteroid.direcao.Y)
                $asteroid.shape.DrawLines(1,$corMira)

                if($asteroid.shape.IsCollidingWithRectangle2D($nave.shape) -and $nave.vivo)
                {
                    $nave.vivo = $false
                    $null = $particulas.Add(
                        @{
                            shape = [engine.Ball2D]::GetNew([int]($nave.shape.position.X+$nave.shape.width /2),([int]$nave.shape.position.Y+$nave.shape.height/2),1,254,0,0,50)
                            ttl = 2
                        }
                    )
                    $null = $particulas.Add(
                        @{
                            shape = [engine.Ball2D]::GetNew([int]($nave.shape.position.X+$nave.shape.width /2),([int]$nave.shape.position.Y+$nave.shape.height/2),4,254,0,0,100)
                            ttl = 2
                        }
                    )
                    $null = $particulas.Add(
                        @{
                            shape = [engine.Ball2D]::GetNew([int]($nave.shape.position.X+$nave.shape.width /2),([int]$nave.shape.position.Y+$nave.shape.height/2),8,254,0,0,200)
                            ttl = 2
                        }
                    )
                    $null = $particulas.Add(
                        @{
                            shape = [engine.Ball2D]::GetNew([int]($nave.shape.position.X+$nave.shape.width /2),([int]$nave.shape.position.Y+$nave.shape.height/2),16,254,0,0,254)
                            ttl = 2
                        }
                    )
                    
                }
            }
        }
        for ($i = 0; $i -lt $asteroids.Count; $i++) {
            if($asteroids[$i].ttl -le 0)
            {
                $asteroids.RemoveAt($i)
            }
        }
    }
    if($particulas.Count -gt 0)
    {
        foreach($p in $particulas)
        {
            if($p.ttl -le 0) {$p = $null}
            if($null -ne $p){
                $p.shape.radius++
                #[Raylib_cs.Raylib]::DrawCircleLin
                [Raylib_cs.Raylib]::DrawCircleLines([int]$p.shape.position.X,[int]$p.shape.position.Y,[int]$p.shape.radius,$p.shape.cor)
               # $p.shape.Draw()
                $p.ttl -= $engine.DeltaTime()
            }
        }
        for ($i = 0; $i -lt $particulas.Count; $i++) {
            if($particulas[$i].ttl -le 0)
            {
                $particulas.RemoveAt($i)
            }
        }
    }

    [Raylib_cs.Raylib]::ClearBackground($engine.GetNewColor(0,0,0,254))
    #$engine.ClearFrameBackground();

    $engine.ClearFrame();

    $engine.SetTitleWindow($nave.vivo ? "Points: $pontuacao" :"You lost, please restart your game. Points: $pontuacao")
}

$engine.CloseWindow();
