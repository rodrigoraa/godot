# Relatório — Atividade 2

## 1. As duas fases

### Fase 1

**Tema:** A primeira fase tem como tema principal um ambiente de inverno, com terreno de neve, plataformas e diferentes camadas no fundo.
**O que o jogador faz:** O jogador precisa avançar pela fase, saltando entre plataformas e evitando cair na água e na lava até chegar ao final.
**Decisão de desenho:** Comecei com um percurso mais simples e fui colocando trechos com mais altura e obstáculos para que a dificuldade aumentasse aos poucos, sem deixar o início muito difícil.

### Fase 2

**Tema:** A segunda fase utiliza um ambiente de floresta/tropical, com bastante vegetação e um percurso com maior variação vertical.
**O que o jogador faz:** O jogador continua avançando pelas plataformas e evitando os obstáculos, mas também pode explorar o cenário e encontrar uma passagem para uma área bônus.
**Decisão de desenho:** Fiz essa fase mais vertical que a primeira e coloquei a área secreta fora do caminho obrigatório, para recompensar quem explora em vez de apenas seguir até o final.

## 2. O parallax

Na Fase 1, os valores de `motion_scale` usados foram:

* Camada 5: `Vector2(0.1, 0)`
* Camada 4: `Vector2(0.2, 0.2)`
* Camada 3: `Vector2(0.35, 0.3)`
* Camada 2: `Vector2(0.3, 0.4)`
* Camada 1: `Vector2(0.25, 0.5)`

Na Fase 2, os valores foram:

* Camada 6: `Vector2(0, 0)`
* Camada 5: `Vector2(0.2, 0.5)`
* Camada 4: `Vector2(0.3, 0.5)`
* Camada 3: `Vector2(0.4, 0.5)`
* Camada 2: `Vector2(0.5, 0)`

Cheguei nesses valores testando o movimento da câmera durante o percurso. A ideia foi fazer as partes mais distantes do fundo se moverem menos e as partes mais próximas se moverem mais, criando a sensação de profundidade.

Na primeira tentativa eu estava usando uma progressão mais simples e o movimento vertical das camadas ficou estranho quando comecei a subir pelas plataformas. O fundo dava a impressão de estar flutuando junto com o jogador. Na versão final passei a controlar os valores de X e Y separadamente. Algumas camadas ficaram praticamente paradas no eixo Y e outras acompanham mais o movimento vertical. Fui ajustando os valores durante os testes até o cenário continuar dando sensação de profundidade sem parecer solto do restante da fase.

## 3. A área secreta

A área secreta está ligada à Fase 2. A pista fica em uma parte anterior do percurso normal, para o jogador perceber que existe algo diferente antes de encontrar a passagem.

A entrada propriamente dita fica escondida em um trecho de terreno falso da Fase 2. Atrás dele existe uma área chamada `bonus`, que leva para a `fase3`. Essa terceira cena funciona como a área bônus e, ao terminar, o jogador volta para a Fase 2.

Eu separei a pista da entrada porque, se as duas estivessem exatamente no mesmo lugar, a pista praticamente entregaria o segredo. Colocando a informação antes e deixando a entrada escondida mais adiante, o jogador precisa lembrar do que viu e explorar o cenário para descobrir a passagem.

## 4. A câmera

Escolhi usar a câmera como um nó independente do Player. Em vez de ser filha do personagem, ela procura no início da cena um nó que esteja no grupo `player` e depois acompanha a posição global dele.

Escolhi essa forma porque consigo deixar a câmera separada do personagem e configurar os limites de cada fase individualmente. Isso foi importante porque as fases possuem alturas diferentes: a Fase 2, por exemplo, permite que a câmera suba muito mais do que a Fase 1.

A outra possibilidade seria colocar a `Camera2D` diretamente como filha do Player. Isso simplificaria o acompanhamento, porque ela seguiria o personagem automaticamente, mas eu perderia parte da independência entre o jogador e a câmera. Também ficaria menos organizado controlar comportamentos e limites específicos para cada fase.

## 5. A transição entre fases

A chegada ao final da fase é detectada por uma `Area2D`. Quando o Player entra nessa área, o sinal `body_entered` é disparado.

A troca de cena não deve ser feita diretamente dentro dessa detecção porque o sinal acontece enquanto o sistema de física ainda está processando a colisão. Trocar a cena naquele mesmo momento pode remover os nós da cena atual, inclusive os objetos que participam da colisão, enquanto o Godot ainda está processando essa informação.

Por isso usei:

`call_deferred("load_next_scene")`

O `call_deferred()` deixa a chamada para depois do processamento atual. Primeiro o Godot termina de tratar a colisão e o sinal e, em seguida, executa `load_next_scene()`, que chama `change_scene_to_file()`. Dessa forma a troca acontece em um momento seguro.

## 6. O que travou

Um dos problemas que mais me fez perder tempo foi a passagem de uma fase para outra. Eu chegava até a área de final da fase, mas nada acontecia.

No começo achei que o problema estava no código de troca de cena. Como eu estava trabalhando com o `next_level`, com o nome do arquivo e com o `call_deferred()`, minha primeira suspeita foi que algum desses pontos estivesse errado. Conferi o sinal `body_entered`, o nome da próxima cena e a função responsável por fazer a troca.

O código, porém, estava correto. O problema real estava nas camadas de colisão. O `LevelEnd` estava configurado para detectar o Player, mas o Player não estava na camada que aquela área estava procurando. Por isso a colisão visualmente acontecia, mas o `body_entered` necessário para executar o código não era detectado corretamente.

Depois de conferir as configurações de física, coloquei o Player na camada correta e deixei o `LevelEnd` com a máscara correspondente. A partir desse ajuste, a mesma função que eu já tinha escrito começou a funcionar normalmente.

Esse problema foi importante porque mostrou que nem todo erro está no script. Eu estava procurando inicialmente um problema de programação, mas a causa estava na configuração dos nós e das camadas de física. O caminho para encontrar o erro foi conferir cada parte da sequência: primeiro se a área estava sendo atingida, depois se o sinal poderia detectar o Player e, por último, se a função de troca de cena estava correta.
