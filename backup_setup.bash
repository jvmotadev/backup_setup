#!/bin/bash
#Alunos Angelo Prebianca, Joao Machado, Marcos Renato
#Projeto final de Administraçao de Sistemas
#Script para gerar um backup de arquivos no linux
origens=()
Menu(){
    echo "Bem vindo ao backup de arquivos, selecione uma das opcoes a seguir"
    echo "1 - Adicionar pasta de origem (podem ser varias)"
    echo "2 - Listar origens para remover"
    echo "3 - Adicionar destino do backup (unico)"
    echo "4 - Definir frequencia de backup"
    echo "5 - Iniciar e agendar backup"
    echo "6 - Cancelar backup"
    read option
    case $option in
        1) adcOrigem ;;
        2) rmvOrigem ;;
        3) setDestino ;;
        4) freqBackup ;;
        5) startBackup ;;
        6) echo "Backup cancelado" ; exit ;;
        *) echo "Opção inexistente." ; echo ; Menu ;;
    esac
}

adcOrigem(){
    echo
    echo "Opcao 1 selecionada - Origem"
    echo "Digite um path que deseja fazer backup"
    echo "Ele sera adicionado a lista de pastas a serem salvas"
    echo "Use o formato -> /home/usuario/pasta"
    readAndValidateOrigem
}

rmvOrigem(){
    echo
    echo "Opcao 2 selecionada - Remover Origem"
    if [ ${#origens[@]} -eq 0 ]; then
        echo "Nenhuma origem para remover"
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
                echo "Origem removida com sucesso"
                echo
                Menu
                break
            else
                echo "Índice inválido"
            fi
        done
    fi
}

setDestino(){
    echo
    echo "Opcao 3 selecionada - Destino"
    if [ -n "$destino" ]; then
        echo "Destino já definido como $destino."
        echo "Deseja mudar o destino? (s/n)"
        read response
        if [[ "$response" != "s" ]]; then
            echo "Destino não alterado."
            echo
            Menu
            return
        fi
    fi
    echo "Digite um path de destino para o backup"
    echo "O backup sera gravado nesta pasta, apenas uma pasta pode ser selecionada"
    echo "Use o formato -> /home/usuario/pasta"
    readAndValidateDestino
}

#freqBackup(){}
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
            echo "O diretório $dir já está na lista de origens. Por favor, digite outro caminho."
        elif [ -d "$dir" ]; then
            origens+=("$dir")
            echo "Diretório $dir adicionado à lista de origens."
            echo
            Menu
            break
        else
            echo "Diretório inválido. Por favor, tente novamente."
        fi
    done
}

readAndValidateDestino(){
    echo
    while true; do
        read dir
        if [ -d "$dir" ]; then
            destino="$dir"
            echo "Destino $dir selecionado."
            echo
            Menu
            break
        else
            echo "O diretório $dir não existe. Deseja criá-lo? (s/n)"
            read response
            if [[ "$response" == "s" ]]; then
                mkdir -p "$dir"
                if [ $? -eq 0 ]; then
                    destino="$dir"
                    echo "Destino $dir criado e selecionado."
                    echo
                    Menu
                    break
                else
                    echo "Falha ao criar o diretório $dir. Por favor, tente novamente."
                fi
            else
                echo "Por favor, digite um caminho válido."
            fi
        fi
    done
}

listOrigens(){
    echo
    echo "Selecione o índice da origem que deseja remover:"
    for i in "${!origens[@]}"; do
        echo "$i - ${origens[$i]}"
    done
    echo "Digite 'm' para voltar ao menu"
}
Menu