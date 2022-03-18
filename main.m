% Simulador para resolver a equacao de eliptica (2-D) 
% Desenvolvedor: Prof. Fernando R.L. Contreras

%% Este codigo somente roda MONOFASICO
clear all
clc
format short
global coord centelem elem esurn1 esurn2 nsurn1 nsurn2 bedge inedge ...
    normals esureface1 esureface2 esurefull1 esurefull2 elemarea dens ...
    visc satlimit pormap bcflag courant totaltime filepath foldername;
%%========================================================================%

[coord,centelem,elem,esurn1,esurn2,nsurn1,nsurn2,bedge,inedge,normals,...
    esureface1,esureface2,esurefull1,esurefull2,elemarea,dens,visc,...
    satlimit,pormap,bcflag,courant,totaltime,filepath,foldername,kmap,...
    wells] = preprocessor;

%% NOTAS 
% 1. Para o interpolador com correcao de pontos harmonicos precisa ainda
% implementar o caso artigo Zhang Kobaise figura 12. 
% 2. Ainda falta investir no termo gravitacional
% 3. Verificar o codigo eLPW2
% 4. Deve-se investir em precondicionares
%% funcao que modificacao de bedge
% esta funcao deve ser ativado quando utilizado algumas malhas patologicas
%[bedge]=modificationbedge(bedge);

%% calculo o flag do elemento que deseja
%   a=6287;
%   b=445;
%   c=5740;
%   d=0;
%   [elemento]=searchelement(a,b,c,d)
%% escolha o tipo de erro discreto que deseja usar
% erromethod1 ---> erro utilizado por Gao e Wu 2010
% erromethod2 --->  ''     ''     por Lipnikov et al 2010
% erromethod3 --->  ''     ''     por Eigestad et al 2005
% erromethod4 --->  ''     ''     por Shen e Yuan 2015
erromethod='erromethod1';
%% defina o tipo de solver 
% tpfa      --> metodo Linear dos volumes finito TPFA
% mpfad     --> (MPFA-D)
% lfvLPEW   --> metodo linear basedo no m�todo n�o linear usando LPEW (MPFA-HD), ter cuidado linha 52 e 54 do preNLFV
% lfvHP     --> (MPFA-H)
% lfvEB     --> metodo completamente baseado na face (MPFA-BE), ainda os
% testes nao foram feitos
% nlfvLPEW  --> (NLFV-PP)
% nlfvDMPSY --> metodo n�o linear que preserva DMP baseado no artigo (Gao e Wu, 2013) e (Sheng e Yuan, 20...)
% nlfvHP    --> metodo nao linear baseado em pontos harmonicos
% nlfvPPS   --> 
pmetodo='nlfvLPEW';
%% metodo de intera��o: picard, newton, broyden, secant,
% m�todo de itere��o proprio de m�todos n�o lineares iterfreejacobian,iterdiscretnewton, JFNK
% iteration='iterdiscretnewton';
% iteration='iterbroyden';
% iteration='JFNK';
% iteration='fullpicard';
% iteration='MPE'; 
% iteration='RRE'; % picard com acelerador rank reduced extrapolation
  iteration='AA';  % picard com aceleracao de Anderson
%iteration='iterhybrid';
%% defina o ponto de interpolacao
interpol='LPEW2';
%interpol='LPEW1';
%interpol='eLS';
%interpol='eLPEW2';
%% correcao dos pontos harmonicos
% digite 'yes' ou 'no'
correction= 'no';
%% digite segundo o benchmark
% procure no "benchmarks.m" o caso que deseja rodar e logo digite o nome
% do caso
benchmark='edqueiroz'; 
%% com termo gravitacional
% com termo gravitacional 'yes' ou 'no'
gravitational='no';
%% adequa��o das permeabilidades, otros entes fisico-geometricos segundo o bechmark
[elem,kmap,normKmap,solanal,bedge,fonte,velanal,grav]=benchmarks(benchmark,...
    kmap,elem,bedge);

% F faces na vizinhanca de um elemento
% V 
% N
[F,V,N]=elementface;
%% pre-processador local
[pointarmonic,parameter,gamma,p_old,tol,nit,er,nflagface,nflagno,...
    weightDMP,Hesq,Kde,Kn,Kt,Ded,auxface,calnormface,gravresult,gravrate,w,s]=...
    preNLFV(kmap,N,pmetodo,benchmark,bedge,grav,gravitational,correction,interpol);
nflag=nflagno;
% n�o habilite
%[aroundface]=aroundfacelement(F,pointarmonic);
%% calculo das mobilidades
% mobilidade sera utilizado unitario porque este simulador "in house" somente
% trata problemas de escoamento monofasico
mobility=zeros(size(bedge,1)+size(inedge,1),1);
mobility(:)=1;
%% Solver: Calculo da pressao pelos m�todo lineares e nao-lineares
[p,errorelativo,flowrate,flowresult,tabletol,coercividade]=solverpressure(...
    kmap,nflagface,nflagno,fonte, tol,...
    nit,p_old,mobility,gamma,wells,parameter,pmetodo,...
    Hesq, Kde, Kn, Kt, Ded,weightDMP,auxface,...
    benchmark,iteration,nflag,calnormface,gravresult,gravrate,w,s);

% pos-processador no visit
% postprocessor(full(abs(p-solanal)),1)
% postprocessor(full(p),2)
% postprocessor(solanal,3)
%% calculo do erro, pressao maxima e minima
errorateconv(solanal, p, velanal,flowrate,erromethod,benchmark)

%hold on
%grid on
%% plota os erros
%plot(tabletol(:,1),log(tabletol(:,2)),'s-m','LineWidth',2)
%ylabel('log(Error)')
%xlabel('Number iterations')

