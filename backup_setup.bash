#!/bin/bash
#Alunos Angelo Prebianca, Joao Machado, Marcos Renato
#Projeto final de Administraçao de Sistemas
#Script para gerar um backup de arquivos no linux

##cores dos logs
GREEN='\033[0;32m'
RED='\033[31m'
BLUE='\033[34m'
WHITE='\033[0m'

origens=()
Menu(){
    echo -e "${BLUE}Bem vindo ao backup de arquivos, selecione uma das opcoes a seguir${WHITE}"
    echo -e "${BLUE}1 - Adicionar pasta de origem (podem ser varias)${WHITE}"
    echo -e "${BLUE}2 - Listar origens para remover${WHITE}"
    echo -e "${BLUE}3 - Adicionar destino do backup (unico)${WHITE}"
    echo -e "${BLUE}4 - Definir frequencia de backup${WHITE}"
    echo -e "${BLUE}5 - Iniciar e agendar backup${WHITE}"
    echo -e "${BLUE}6 - Fechar app de backup${WHITE}"
    read option
    case $option in
        1) adcOrigem ;;
        2) rmvOrigem ;;
        3) setDestino ;;
        4) getInput ;;
        5) startBackup ;;
        6) echo -e "${GREEN}Backup cancelado${WHITE}" ; exit ;;
        *) echo -e "${RED}Opção inexistente.${WHITE}" ; echo ; Menu ;;
    esac
}

adcOrigem(){
    echo
    echo -e "${BLUE}Opcao 1 selecionada - Origem${WHITE}"
    echo -e "${BLUE}Digite um path que deseja fazer backup${WHITE}"
    echo -e "${BLUE}Ele sera adicionado a lista de pastas a serem salvas${WHITE}"
    echo -e "${BLUE}Use o formato -> /home/usuario/pasta ${WHITE}"
    readAndValidateOrigem
}

rmvOrigem(){
    echo
    echo -e "${BLUE}Opcao 2 selecionada - Remover Origem${WHITE}"
    if [ ${#origens[@]} -eq 0 ]; then
        echo -e "${RED}Nenhuma origem para remover${WHITE}"
        echo
        Menu
    else
        listOrigens
        while true; do
            read index
            if [[ $index == "m" ]]; then
                Menu
                break
            elif [[ $index =~ ^[0-9]+$ ]] && [ $index -ge 0 ] && [ $index -lt ${#origens[@]} ]; then
                unset 'origens[$index]'
                origens=("${origens[@]}")
                echo -e "${GREEN}Origem removida com sucesso${WHITE}"
                echo
                Menu
                break
            else
                echo -e "${RED}Índice inválido${WHITE}"
            fi
        done
    fi
}

setDestino(){
    echo
    echo -e "${BLUE}Opcao 3 selecionada - Destino${WHITE}"
    if [ -n "$destino" ]; then
        echo -e "${RED}Destino já definido como $destino.${WHITE}"
        echo -e "${BLUE}Deseja mudar o destino? (s/n)${WHITE}"
        read response
        if [[ "$response" != "s" ]]; then
            echo -e "${GREEN}Destino não alterado.${WHITE}"
            echo
            Menu
            return
        fi
    fi
    echo -e "${BLUE}Digite um path de destino para o backup${WHITE}"
    echo -e "${BLUE}O backup sera gravado nesta pasta, apenas uma pasta pode ser selecionada${WHITE}"
    echo -e "${BLUE}Use o formato -> /home/usuario/pasta${WHITE}"
    readAndValidateDestino
}


#startBackup(){}

readAndValidateOrigem(){
    echo
    while true; do
        read dir
        # Verifica se a origem já foi adicionada
        origem_existente=false
        for origem in "${origens[@]}"; do
            if [[ "$origem" == "$dir" ]]; then
                origem_existente=true
                break
            fi
        done

        if $origem_existente; then
            echo -e "${RED}O diretório $dir já está na lista de origens. Por favor, digite outro caminho.${WHITE}"
        elif [ -d "$dir" ]; then
            origens+=("$dir")
            echo -e "${GREEN}Diretório $dir adicionado à lista de origens.${WHITE}"
            echo
            Menu
            break
        else
            echo -e "${RED}Diretório inválido. Por favor, tente novamente.${WHITE}"
        fi
    done
}

readAndValidateDestino(){
    echo
    while true; do
        read dir
        if [ -d "$dir" ]; then
            destino="$dir"
            echo -e "${GREEN}Destino $dir selecionado.${WHITE}"
            echo
            Menu
            break
        else
            echo -e "${BLUE}O diretório $dir não existe. Deseja criá-lo? (s/n)${WHITE}"
            read response
            if [[ "$response" == "s" ]]; then
                mkdir -p "$dir"
                if [ $? -eq 0 ]; then
                    destino="$dir"
                    echo -e "${GREEN}Destino $dir criado e selecionado.${WHITE}"
                    echo
                    Menu
                    break
                else
                    echo -e "${RED}Falha ao criar o diretório $dir. Por favor, tente novamente.${WHITE}"
                fi
            else
                echo -e "${RED}Por favor, digite um caminho válido.${WHITE}"
            fi
        fi
    done
}

listOrigens(){
    echo
    echo -e "${BLUE}Selecione o índice da origem que deseja remover:${WHITE}"
    for i in "${!origens[@]}"; do
        echo -e "${BLUE}$i - ${origens[$i]}${WHITE}"
    done
    echo -e "${BLUE}Digite 'm' para voltar ao menu${WHITE}"
}



# Função para solicitar e validar entrada do usuário
freqBackup() {
    local prompt="$1"
    local var_name="$2"
    local regex="$3"

    while true; do
        read -r -p "$(echo -e $prompt)" input
        input="${input#"${input%%[![:space:]]*}"}"   # Remove leading whitespace
        input="${input%"${input##*[![:space:]]}"}"   # Remove trailing whitespace

        if [[ $input =~ $regex ]]; then
            eval "$var_name='$input'"
            break
        else
            echo -e "${RED}Entrada inválida. Por favor, tente novamente.${WHITE}"
        fi
    done
}



# Solicita as entradas do usuário
getInput(){

    echo -e "${BLUE}Bem-vindo ao agendador de tarefas do cron.${WHITE}"
    
    if [[ -n "$cron_schedule" ]]; then
        echo -e "${BLUE}Já existe um agendamento definido: '$cron_schedule'. Deseja alterá-lo? (s/n)${WHITE}"
        read response
        if [[ "$response" != "s" ]]; then
            echo -e "${GREEN}Agendamento mantido: '$cron_schedule'${WHITE}"
            return
        fi
    fi
    
    freqBackup "${BLUE}Digite o minuto (0-59 ou ): ${WHITE}" minute '^([0-5]{0,1}[0-9]{1}|\*)$'
    freqBackup "${BLUE}Digite a hora (0-23 ou *): ${WHITE}" hour '^([0-9]|0[0-9]|1[0-9]|2[0-3]|\*)$'
    freqBackup "${BLUE}Digite o dia do mês (1-31 ou *): ${WHITE}" day_of_month '^([1-9]|0[1-9]|[12][0-9]|3[01]|\*)$'
    freqBackup "${BLUE}Digite o mês (1-12 ou *): ${WHITE}" month '^([1-9]|0[1-9]|1[0-2]|\*)$'
    freqBackup "${BLUE}Digite o dia da semana (0-6 ou *): ${WHITE}" day_of_week '^([0-6]|\*)$'
    # Monta a string do cron
    cron_schedule="$minute $hour $day_of_month $month $day_of_week"
    echo -e "${GREEN}O schedule é: '$cron_schedule'${WHITE}"
    echo
    Menu
}


startBackup(){
    # Check if any origins and destination are set
    if [ ${#origens[@]} -eq 0 ]; then
        echo -e "${RED}Nenhuma origem definida. Por favor, adicione pelo menos uma pasta de origem.${WHITE}"
        Menu
        return
    fi

    if [ -z "$destino" ]; then
        echo -e "${RED}Nenhum destino definido. Por favor, defina um destino para o backup.${WHITE}"
        Menu
        return
    fi

    # Concatenate all origins into a single string
    origem=""
    for dir in "${origens[@]}"; do
        origem+="$dir "
    done


    backup_script="#!/bin/bash
# Script de backup gerado automaticamente
logfile=\"$destino/backup.log\"
rsync -auv --progress --delete --exclude='.DS_Store' --delete-excluded --log-file=\$logfile $origem \"$destino/\""

    # Create the backup script file
    backup_script_path="/tmp/backup_script.sh"
    echo "$backup_script" > "$backup_script_path"
    chmod +x "$backup_script_path"

    # Check if the cron schedule is set
    if [[ -n "$minute" && -n "$hour" && -n "$day_of_month" && -n "$month" && -n "$day_of_week" ]]; then
        # Remove previous backup jobs from crontab
        crontab -l | grep -v "$backup_script_path" | crontab -

        # Add the new backup job to crontab
        cron_schedule="$minute $hour $day_of_month $month $day_of_week"
        (crontab -l; echo "$cron_schedule $backup_script_path") | crontab -
        
        echo -e "${GREEN}Backup agendado para $cron_schedule.${WHITE}"
    else
        echo -e "${BLUE}Nenhum agendamento definido. O backup será executado apenas uma vez.${WHITE}"
    fi

    # Execute the backup script once
    "$backup_script_path"

    echo -e "${GREEN}Backup agendado e executado com sucesso.${WHITE}"
    echo
    Menu
}


Menu
