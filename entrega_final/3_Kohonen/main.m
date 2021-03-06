%==========================================================================	
function main()
    
    %n = gpuDeviceCount
    clc;
	clear ; close all
    usuario = 'nicol';
    nucleos = 2;
	c_temp = 0;
    casas_decimais = 2;
    for iteracao=1:1 
        %------------------------------------------------------------------
        mkdir(strcat('C:/Users/',usuario,'/Desktop/Redes_Neurais_Jogo_Serio/',num2str(iteracao)));
        str_quest = 'dados/questionario1.csv';
        str_quest_final = 'dados/questionario2.csv';
        str_benigno = 'dados/dadosTedioC.csv';
		str_maligno = 'dados/dadosEstresseC.csv';
        %------------------------------------------------------------------
        %str_quest = 'dados/quest.csv'; %vers?o 0
        %str_quest_final = 'dados/quest.csv'; %vers?o 0
        %str_benigno = 'dados/h0.csv'; %vers?o 0
		%str_maligno = 'dados/h1.csv'; %vers?o 0
        %------------------------------------------------------------------
        start_time = cputime;
        main_tradicional_auxiliar(str_quest,str_quest_final,str_benigno,str_maligno, iteracao,usuario,nucleos,casas_decimais);
        stop_time = cputime;
                        
        c_temp = c_temp + 1; 
        tempo_total(c_temp) = stop_time-start_time;
		%------------------------------------------------------------------
    end
    
    save(strcat('C:/Users/',usuario,'/Desktop/Redes_Neurais_Jogo_Serio/tempo_total.txt'),'tempo_total', '-ASCII');
    
%==========================================================================	
function main_tradicional_auxiliar(str_quest, str_quest_final, str_benigno, str_maligno, iteracao,usuario,nucleos,casas_decimais)
	    
	addpath('dados');
    %----------------------------------------------------------------------
    semente = iteracao;
	rng(semente);
    %----------------------------------------------------------------------
    cluster = 6; %emo??es padr?es
    %-------------Estrat?gia sem cluster-----------------------------------
    %[entrada_benigno,entrada_benigno_som] = processamento_som(str_benigno,1);%vers?o 0	
	%[entrada_maligno,entrada_maligno_som] = processamento_som(str_maligno,2);%vers?o 0
	[entrada_benigno,entrada_benigno_som] = processamento_som_v1(str_benigno,1);	
	[entrada_maligno,entrada_maligno_som] = processamento_som_v1(str_maligno,2);	   
    %--------------Aprendizado n?o-supervisionado--------------------------
    [entrada_quest] = processamento_quest_v1(str_quest);
    [entrada_quest_fim] = processamento_quest_final_v1(str_quest_final);
    %[entrada_quest,entrada_quest_fim] = processamento_quest(str_quest); %vers?o 0  
    som_v1(iteracao, entrada_quest, entrada_quest_fim, entrada_benigno_som, entrada_maligno_som);
    save(strcat('dados/without_cluster/h0.csv'),'entrada_benigno', '-ASCII');
    save(strcat('dados/without_cluster/h1.csv'),'entrada_maligno', '-ASCII'); 
    %-------------Estrat?gia sem cluster-----------------------------------
    main_auxiliar(iteracao,entrada_benigno,entrada_maligno,nucleos,casas_decimais) 
    str = strcat('C:/Users/',usuario,'/Desktop/Redes_Neurais_Jogo_Serio/',num2str(iteracao),'/without_cluster/');
	imprime_resultados(str, 'ELM_v3_balanceado');    
    %-------------Estrat?gia com cluster-----------------------------------    
    for cc=1:cluster % uma intelig?ncia artificial para cada cluster
        [entrada_benigno] = processamento_cluster_som(cc,entrada_quest_fim,entrada_benigno_som,1);	
        [entrada_maligno] = processamento_cluster_som(cc,entrada_quest_fim,entrada_maligno_som,2);
        main_auxiliar(iteracao,entrada_benigno,entrada_maligno,nucleos,casas_decimais);
        save(strcat('dados/with_cluster/',num2str(cc),'/h0.csv'),'entrada_benigno', '-ASCII');
        save(strcat('dados/with_cluster/',num2str(cc),'/h1.csv'),'entrada_maligno', '-ASCII'); 
        str = strcat('C:/Users/',usuario,'/Desktop/Redes_Neurais_Jogo_Serio/',num2str(iteracao),'/with_cluster/',num2str(cc),'/');
        imprime_resultados(str, 'ELM_v3_balanceado');
    end
    %----------------------------------------------------------------------
%==========================================================================    
function main_auxiliar(iteracao,entrada_benigno,entrada_maligno,nucleos,casas_decimais)

    %----------------------------------------------------------------------
    addpath('ELM_v3_balanceado'); 
    addpath('normalizar');
	addpath('preencheDados'); 
    addpath('aleatorio');
	addpath('dados');
    %----------------------------------------------------------------------
    semente = iteracao;
	rng(semente);
    %----------------------------------------------------------------------
    classes = 2;
	kfold = 10;
    total = 30;
    %----------------------------------------------------------------------
    [index_total_benigno, a] = size(entrada_benigno);
    [index_total_maligno, a] = size(entrada_maligno);
    
    %---------iguala a qtd. das amotras pela menor das classes-------------
    index_total = min(index_total_benigno,index_total_maligno);
    entrada_benigno = entrada_benigno(1:index_total,:);
    entrada_maligno = entrada_maligno(1:index_total,:);
    
    [index_total_benigno, a] = size(entrada_benigno);
    [index_total_maligno, a] = size(entrada_maligno);
    
    %----------------------------------------------------------------------
    [entrada, aleatorio, atributos] =...
	aleatorio_funcao(entrada_benigno,entrada_maligno,...
     				     index_total_benigno,index_total_maligno); 
	%----------------------------------------------------------------------
    entradaFim = atributos;
    normalizar_entrada = 0;       
	%----------------------------------------------------------------------    
    delete('ELM_v3_balanceado/iteracao/*');
    delete('ELM_v3_balanceado/boxplot/*');
    delete('ELM_v3_balanceado/confusao/*');
    %----------------------------------------------------------------------    
    elm_main(entradaFim, total, kfold, classes, normalizar_entrada, entrada, aleatorio,casas_decimais,nucleos,'ELM_v3_balanceado');
    %----------------------------------------------------------------------
%==========================================================================
function imprime_resultados(str, tecnica)


    stra = strcat(str,tecnica,'/boxplot');
    
    strb = strcat(tecnica,'/boxplot/*');
    stra
    strb
    
    copyfile(strcat(tecnica,'/boxplot/*'), stra);
    
	stra = strcat(str,tecnica,'/confusao');
	copyfile(strcat(tecnica,'/confusao/*'), stra);
    
	stra = strcat(str,tecnica,'/iteracao');	
	copyfile(strcat(tecnica,'/iteracao/*'), stra);
    
 %==========================================================================

     
    