#!/bin/bash

# ================================================================
# Script de Configuração do Ambiente de Desenvolvimento
#
# Este script instala:
# - Neovim
# - Visual Studio Code (VSCode)
# - insominia, steam,
# ================================================================

# Cores para melhor legibilidade
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para exibir mensagens de progresso
show_message() {
	echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

# Função para verificar se um comando foi bem-sucedido
check_status() {
	if [ $? -eq 0 ]; then
		echo -e "${GREEN}✓ Sucesso!${NC}"
	else
		echo -e "${YELLOW}⚠ Houve um problema. Verifique os logs acima.${NC}"
	fi
}

# Verifica se estamos em um sistema Debian/Ubuntu
if [ ! -f /etc/debian_version ]; then
	echo -e "${YELLOW}Atenção: Este script foi projetado para sistemas Debian/Ubuntu.${NC}"
	echo -e "${YELLOW}Pode ser necessário adaptá-lo para sua distribuição.${NC}"

	read -p "Deseja continuar mesmo assim? (s/n): " choice
	if [ "$choice" != "s" ]; then
		echo "Instalação cancelada."
		exit 1
	fi
fi

# Atualizar lista de pacotes
show_message "Atualizando repositórios..."
sudo apt update
check_status

# Instalar dependências essenciais
show_message "Instalando dependências essenciais..."
sudo apt install -y curl wget
sudo apt install fd-find
sudo apt install preload
sudo apt install cpufrequtils

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

check_status
## novas dependencias

# Instalar Rust
show_message "Instalando Rust..."
if command -v rustc &>/dev/null; then
	echo "Rust já está instalado."
else
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	sudo apt install cargo

	check_status
	echo "Rust instalado. Versão: $(rustc --version | head -n 1)"
fi
# Instalar Neovim
show_message "Instalando Neovim..."
if command -v nvim &>/dev/null; then
	echo "Neovim já está instalado."
else
	sudo apt install -y neovim
	check_status
	echo "Neovim instalado. Versão: $(nvim --version | head -n 1)"
fi

# Instalar Visual Studio Code (VSCode)
show_message "Instalando Visual Studio Code (VSCode)..."
if command -v code &>/dev/null; then
	echo "VSCode já está instalado."
else
	# Instalar via Snap (opcional)
	read -p "Deseja instalar o VSCode via Snap? (s/n): " install_vscode_snap
	if [ "$install_vscode_snap" = "s" ]; then
		sudo snap install --classic code
	else
		# Instalar via repositório oficial
		sudo apt install -y software-properties-common apt-transport-https wget
		wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
		sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
		sudo apt update
		sudo apt install -y code
	fi
	check_status
	echo "VSCode instalado. Versão: $(code --version | head -n 1)"
fi

# Instalar ZSH
show_message "Instalando ZSH..."
if command -v zsh &>/dev/null; then
	echo "ZSH já está instalado."
else
	sudo apt install -y zsh
	check_status
fi

# Instalar Oh My ZSH
show_message "Instalando Oh My ZSH..."
if [ -d "$HOME/.oh-my-zsh" ]; then
	echo "Oh My ZSH já está instalado."
else
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	check_status
fi

# Definir ZSH como shell padrão
show_message "Definindo ZSH como shell padrão..."
if [ "$SHELL" != "/usr/bin/zsh" ]; then
	chsh -s $(which zsh)
	check_status
fi

# Instalar NVM
show_message "Instalando NVM (Node Version Manager)..."
if [ -d "$HOME/.nvm" ]; then
	echo "NVM já está instalado."
else
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
	check_status

	# Adicionar configurações do NVM ao .zshrc
	cat >>"$HOME/.zshrc" <<'EOF'

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF

	# Carregar NVM imediatamente
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

	# Instalar a última versão LTS do Node.js
	nvm install --lts
	nvm use --lts
	check_status
fi

# Instalar VirtualBox (necessário para o Genymotion)
show_message "Instalando VirtualBox..."
if command -v virtualbox &>/dev/null; then
	echo "VirtualBox já está instalado."
else
	sudo apt install -y virtualbox
	check_status
fi

# Instalar Genymotion
show_message "Instalando Genymotion..."
if [ -d "/opt/genymobile/genymotion" ]; then
	echo "Genymotion já está instalado."
else
	# Criar diretório temporário
	TEMP_DIR=$(mktemp -d)
	cd "$TEMP_DIR"

	# Baixar Genymotion
	wget -q "https://dl.genymotion.com/releases/genymotion-3.6.0/genymotion-3.6.0-linux_x64.bin"

	# Tornar o arquivo executável
	chmod +x genymotion-3.6.0-linux_x64.bin

	# Instalar Genymotion
	sudo ./genymotion-3.6.0-linux_x64.bin -y
	check_status

	# Limpar arquivos temporários
	cd "$HOME"
	rm -rf "$TEMP_DIR"

	# Criar atalho no menu de aplicativos
	cat >~/.local/share/applications/genymotion.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Genymotion
Comment=Android Emulator
Exec=/opt/genymobile/genymotion/genymotion
Icon=/opt/genymobile/genymotion/icons/icon.png
Terminal=false
Categories=Development;
EOF
fi

# Mensagem de conclusão
echo -e "\n${GREEN}==================================${NC}"
echo -e "${GREEN}  Instalação concluída com sucesso!${NC}"
echo -e "${GREEN}==================================${NC}"
echo -e "\nVersões instaladas:"
echo -e "Neovim: $(nvim --version | head -n 1)"
echo -e "VSCode: $(code --version | head -n 1)"
echo -e "ZSH: $(zsh --version)"
echo -e "Node.js: $(node --version)"
echo -e "NPM: $(npm --version)"
echo -e "VirtualBox: $(virtualbox --help | head -n 1 | cut -d ' ' -f 5)"
[ -d "/opt/genymobile/genymotion" ] && echo -e "Genymotion: Instalado em /opt/genymobile/genymotion"
[ -d "/opt/lampp" ] && echo -e "XAMPP: Instalado em /opt/lampp"

echo -e "\n${YELLOW}IMPORTANTE:${NC}"
echo -e "Você pode configurar manualmente o Neovim e o VSCode conforme suas preferências."
echo -e "Para iniciar o XAMPP, use: sudo /opt/lampp/xampp start"
echo -e "Para acessar o painel de controle do XAMPP: sudo /opt/lampp/manager-linux-x64.run"

echo -e "\n${GREEN}Obrigado por usar este script!${NC}"
