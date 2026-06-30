#  Como Gerar o Ícone do Aplicativo

## Situação Atual
O arquivo `logo.svg` está em `assets/images/logo.svg`, mas as ferramentas de geração de ícones (flutter_launcher_icons e icons_launcher) **não suportam arquivos SVG diretamente**. Precisamos converter para PNG.

##  Solução Rápida (Recomendada)

### Passo 1: Converter SVG para PNG

**Opção A - Online (Mais Rápido):**
1. Acesse: https://cloudconvert.com/svg-to-png
2. Faça upload de: `D:\weatherpro\weatherpro\assets\images\logo.svg`
3. Configure:
   - Width: **1024px**
   - Height: **1024px**
4. Clique em **"Convert"**
5. Baixe e salve como: `D:\weatherpro\weatherpro\assets\images\logo.png`

**Opção B - Usando VS Code:**
1. Instale a extensão: **SVG Viewer** ou **SVG**
2. Abra `logo.svg` no VS Code
3. Clique com botão direito → **"Export PNG"**
4. Tamanho: 1024x1024px
5. Salve como `logo.png` na mesma pasta

**Opção C - Photoshop/GIMP:**
1. Abra `logo.svg`
2. Exporte como PNG (1024x1024px)
3. Salve em `assets/images/logo.png`

### Passo 2: Gerar os Ícones

Após criar o arquivo `logo.png`, execute no terminal:

```powershell
flutter pub run icons_launcher:create
```

Ou:

```powershell
dart run icons_launcher:create
```

### Passo 3: Testar

Execute o app no seu celular:

```powershell
flutter run
```

O novo ícone aparecerá na tela inicial do celular!

##  Arquivos Configurados

-  `icons_launcher.yaml` - Arquivo de configuração criado
-  `pubspec.yaml` - Pacote `icons_launcher` adicionado
-  `assets/images/logo.png` - **VOCÊ PRECISA CRIAR ESTE ARQUIVO**

##  Detalhes do Ícone

O logo.svg contém:
- Fundo com gradiente azul (#0BD1FF → #1587FF)
- Ícone de sol (gradiente amarelo/laranja)
- Nuvem branca
- Tamanho: 2500x2500px (será redimensionado para 1024x1024px)

##  Configuração Atual

```yaml
icons_launcher:
  image_path: "assets/images/logo.png"
  platforms:
    android:
      enable: true
      adaptive_background_color: "#0BD1FF"
      adaptive_foreground_image: "assets/images/logo.png"
    ios:
      enable: true
```

##  Troubleshooting

**Problema:** Erro ao executar `icons_launcher:create`
- **Solução:** Verifique se `logo.png` existe em `assets/images/`

**Problema:** Ícone não aparece
- **Solução:** Desinstale e reinstale o app no celular

**Problema:** Ícone deformado
- **Solução:** Verifique se o PNG é quadrado (1024x1024px)

---

 **IMPORTANTE:** Após gerar o PNG, execute `flutter pub run icons_launcher:create` para aplicar as mudanças!
