function [slopeOutput] = slopeOfReflectanceCurve2(wlambda, lookupStruct)


ci   = lookupStruct.mu0;
ce   = lookupStruct.mu;
z    = sqrt(1-wlambda);
Hci = (1+2*ci)./(1+2*ci*z);
Hce = (1+2*ce)./(1+2*ce*z);

incidenceTerm = (wlambda*ci)./((1+2*ci*z).*z);
emergenceTerm = (wlambda*ce)./((1+2*ce*z).*z);

slopeOutput = ((Hci.*Hce)/(4*(ci+ce))).*(1+incidenceTerm+emergenceTerm);


end