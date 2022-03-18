function [J]=aproxmjacobian(Fk,p_new,p_old,nflagface,nflagno,w,s,metodoP,...
    parameter,weightDMP,kmap,fonte,mobility,Hesq, Kde, Kn, Kt, ...
    Ded,calnormface,wells,benchmark)
global elem
nelem=size(elem,1);
J=sparse(nelem,nelem);
x=p_old;
I=eye(nelem);

delta = 1e-3*sqrt(norm(p_old));

for ielem=1:nelem
    %  xi+h
    x=x+ delta*I(:,ielem);
      
    % interpolation point
    [pinterp_new]=pressureinterp(x,nflagface,nflagno,w,s,metodoP,...
        parameter,weightDMP,mobility);
    
    % Calculo da matriz global
    [auxM,auxRHS]=globalmatrix(x,pinterp_new,0,nflagface,nflagno...
        ,parameter,kmap,fonte,metodoP,w,s,benchmark,weightDMP,wells,...
        mobility,Hesq, Kde, Kn, Kt, Ded,calnormface,0);
    % f(xk+1)
    Fkk= auxM*x - auxRHS;
    
    % Montagem da matriz Jacobiano por m�todo Diferencia Finita
    J(1:nelem,ielem)=(Fkk(:)-Fk(:))./(delta);
    
    % Atualiza o vetor "x"
    x=p_old;
    delta=1e-3*sqrt(norm(x));
end

end