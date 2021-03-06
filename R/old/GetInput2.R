#' @title GetInput for VRAP > 2.0
#' @description Read in a .rav file from the original VRAP vrs > 2.0 and assign all the variables
#' @param InFile the name of the .rav file
#' @return Returns the list of all inputs
#' @details VRAP 2.0 uses the same .rav file as VRAP 1.0 but some input lines are ignored.  VRAP 2.0 will also check for a tag `VRAP2` at the start of the .rav file.  If it is present, `GetInput2` knows the rav file is properly adjusted for VRAP  2.0 (VRAPS).  If the tag is not present, the .rav file is assumed to be in VRAP 1.0 form and proceeds unless option that is illegal in VRAP 2.0 is encountered (like covariates).  See the demo rav file in the `inst` folder (see examples).
#' @examples
#' \dontrun{
#' fpath <- system.file("VRAP", "demofiles/Demo-ER.rav", package="VRAPS")
#' file.show(fpath)
#' }

GetInput2 = function(InFile){
  
  #The rav file has , as end of input/separator
  
  inputs = list()
  inputs$InFile = InFile

  readit = function(skip, n){ read.table(InFile,nrows=1,sep=",",stringsAsFactors=FALSE,skip=skip)[1,n] }
  
  # GET TITLE FOR RUN
  inputs$Title = readit(0,1) #line 1
  inputs$VRAPvrs = readit(0,2) #line 1
  inputs$VRAPvrs = ifelse(inputs$VRAPvrs %in% c("VRAP2","VRAPS"),2,1)
  
  #  -------------------- RUN PARAMETERS SECTION ---------------------------------
  #  INPUT RANDOM NUMBER SEED, NUMBER OF CYCLES AND REPETITIONS,
  #   MINIMUM AND MAXIMUM AGE
  inputs$RanSeed = readit(1,1) #line 2, RanSeed
  inputs$NRuns = readit(2,1)
  inputs$NYears = readit(3,1)
  inputs$MinAge = readit(4,1)
  inputs$MaxAge = readit(4,2)
  inputs$ConvergeCrit = readit(5,1) #line 5, ConvergeCrit
  if(class(inputs$RanSeed)!="numeric") stop("rav line 2: RanSeed must be numeric.")
  if(class(inputs$NRuns)!="numeric") stop("rav line 3: NRuns must be numeric.")
  if(class(inputs$NYears)!="numeric") stop("rav line 4: NYears must be numeric.")
  if(class(inputs$MinAge)!="numeric") stop("rav line 5: MinAge must be numeric.")
  if(class(inputs$MinAge)!=2) stop("rav line 5: MinAge must be 2 for VRAP 2.0.")
  if(class(inputs$MaxAge)!="numeric") stop("rav line 5: MaxAge must be numeric.")
  if(class(inputs$MaxAge)!=5) stop("rav line 5: MaxAge must be 5 for VRAP 2.0.")
  if(class(inputs$ConvergeCrit)!="numeric") stop("rav line 6: ConvergeCrit must be numeric.")
  
  #Center covariate not used in VRAP 2.0
  # skip line 6

  # ----- END OF RUN PARAMETERS SECTION ------------------------
  
  # ----- STOCK-RECRUIT SECTION -------------------------------
  # GET FORM OF SPAWNER RECRUIT FUNCTION AND PARAMETERS
  # Currently only RIC2 used in VRAP 2.0, but that may change
  # These are the SR function forms in DM and VRAP 1.0. Note that in the
  #   VRAP 1.0 documentation, the SR functions are written in a different form
  #   but these are the actual forms used in the VRAP 1.0 code (and DM) and
  #   reflect the meaning of the a and b SR parameters in the .rav files (incl for VRAP 1.0)
  # BSRa = productivity parameter
  # BSRb = density dependent prarameter
  # BSRc = marine survival paramater - M^c
  # BSRd = freshwater survival parameter - exp(dF)(d should be entered as negative)
  # HOC2 - Hockey stick R=Min(aS,b)   a = producitvity b=MaxRecruits
  # HOC3 - R = Min(aS,) exp(dF) (freshwater index - may be used to predict smolts)
  # HOC4 - R= Min(aS,) M^c exp(dF)
  # RIC2 - Ricker R=aS exp(-S/b)       a = productvity  b=capacity
  # RIC3 - R= aS exp(-S/b+dF) (incl freshwater index)
  # RIC4 - Ricker with marine survival and freshwater survival
  #        R=aS M^c exp(-S/b+dF)
  # BEV2 - Beverton-Holt R=S/(S/b + 1/a)  a = productivity  b=MaxRecruits
  # BEV3 - R=S/(S/b + 1/a) exp(dF)(incl freshwater index)
  # BEV4 - BH with marine survival and freshwater survival
  #        R=S/(S/b + 1/a) M^c exp(dF)
  
  inputs$SRType = readit(7,1) 
  inputs$SRType = toupper(inputs$SRType)
  SRType=inputs$SRType
  allowedSRType = c("RIC2")
#  allowedSRType = c("HOC2", "HOC3", "HOC4", "BEV2", "BEV3", "BEV4", "RIC2", "RIC3", "RIC4")
  if(!(SRType %in% allowedSRType)) stop(paste("rav line 7: Only allowed SR types are:", paste(allowedSRType, collapse=", ")))
  
  if(SRType %in% c("HOC2", "RIC2", "BEV2")){
    inputs$prod = readit(8,1) # called BSRa in VRAP 1.0
    inputs$BSRa = inputs$prod
    inputs$cap = readit(8,2) # called BSRb in VRAP 1.0
    inputs$BSRb = inputs$cap
    inputs$BSRc = 0;
    inputs$BSRd = 0;
  }
  if(class(inputs$BSRa)!="numeric") stop("rav line 9: All SR parameters must be numeric.")
  if(class(inputs$BSRb)!="numeric") stop("rav line 9: All SR parameters must be numeric.")
  if(class(inputs$BSRc)!="numeric") stop("rav line 9: All SR parameters must be numeric.")
  if(class(inputs$BSRd)!="numeric") stop("rav line 9: All SR parameters must be numeric.")
  
  
  # Skip the next 6 lines which had to do with covariates
  # and jump to line 15 of rav file
  
  # depensation with DL1=depensation esc; DL2 = QET; DR % of predicted R realized at QET
  inputs$depen = readit(15,1)
  inputs$depen = toupper(inputs$depen)
  if(!(inputs$depen %in% c("YES", "NO"))) stop("rav line 16: Unknown depensation selection (yes/no only)")  
  if(!(inputs$depen %in% c("NO"))) stop("rav line 16: VRAP 2.0 does not implement depensation")
  inputs$DL1 = readit(16,1)
  inputs$DL2 = readit(16,2)
  inputs$DR = readit(16,3)
  if(!is.numeric(inputs$DL1)) stop("rav line 17: DL1 should be numeric.")
  if(!is.numeric(inputs$DL2)) stop("rav line 17: QET should be numeric.  Enter 0 if no quasi-extinction threshold (i.e. threshold = 0).")
  if(!is.numeric(inputs$DR)) stop("rav line 17: DR (3rd param) should be numeric.")
  if(inputs$depen=="NO"){
    if(inputs$DL1 != 0) stop("rav line 17: if no depensation, DL1 should be 0.")
    if(inputs$DR != 1) stop("rav line 17: if no depensation, DR (3rd param) should be 1.")
  }
  if(inputs$DL2 >= inputs$cap) stop("rav line 17: QET should not be greater than capacity.")
  
  # Determine recruits from adult spawners (Must be YES for VRAP 2.0)
  inputs$EscChoice = readit(17,1)
  inputs$EscChoice = toupper(inputs$EscChoice)
  if(!(inputs$EscChoice %in% c("YES", "NO"))) stop("rav line 18: Unknown escapement choice selection (yes/no only)")  
  if(!(inputs$EscChoice %in% c("YES"))) stop("rav line 18: Escapement choice selection must be YES for VRAP 2.0.")  
  
  # GET PARAMETERS TO ADD VARIABILITY TO STOCK RECRUIT FUNCTION
  #   if GAMMA, SRErrorA and B are shape and scale
  #   if LOGNORMAL, SRErrorA and B are log sd and autocorrelation

  inputs$errorType = readit(18,1)
  inputs$errorType = toupper(inputs$errorType)
  if(inputs$errorType == "YES" & inputs$VRAPvrs==1) inputs$errorType=="GAMMA"
  if(!(inputs$errorType %in% c("GAMMA","LOGNORMAL"))) stop("rav line 19: errorType must be GAMMA or LOGNORMAL for VRAP 2.0.")  
  if( inputs$errorType %in% c("GAMMA","LOGNORMAL") ){
    inputs$SRErrorA = readit(19,1) 
    inputs$SRErrorB = readit(19,2) 
  }
  if(class(inputs$SRErrorA)!="numeric") stop("rav line 20: SRErrorA must be numeric.")
  if(class(inputs$SRErrorB)!="numeric") stop("rav line 20: SRErrorB must be numeric.")

  # Skip next 2 lines which were for smolt to adult survival variability via
  # beta distribution.
  
  # Set the base ER or Pop level.  Only 
  if(inputs$VRAPvrs==1){
    inputs$NumBreakPoints = readit(22,1)
    if(inputs$NumBreakPoints != 0) stop("rav line 23: For VRAP 2.0, NumBreakPoints must be 0.")
    inputs$BaseRegime = readit(23,1) #required for VRAP 2.0 since no breaks
    if(inputs$BaseRegime != 1) stop("rav line 24: For VRAP 2.0, BaseRegime must be 1.")
    inputs$TargetU = readit(24,1) #not used in VRAP 2.0 but value needed for backwards compatibility
    if(class(inputs$TargetU)!="numeric") stop("rav line 25: TargetU must be numeric.")
  }
  
  # --------- END OF STOCK RECRUIT SECTION -----------------------------
  
  # --------- FISHERY MANAGEMENT PARAMETERS ---------------------------
  # INPUT THE NUMBER OF BREAKPOINTS AND DIMENSION ARRAYS
  # Skip to line 26; VRAP 2.0 does not include breakpoints
  
  # INPUT PARAMETERS FOR MANAGEMENT ERROR
  inputs$MgmtError = readit(25,1)
  inputs$MgmtError = toupper(inputs$MgmtError)
  if(!(inputs$MgmtError %in% c("YES", "NO"))) stop("rav line 26: Unknown manag error selection (yes/no only)")
  # Read in dummy values if management error is No
  if(inputs$MgmtError == "YES"){
    inputs$MgmtError = TRUE
    inputs$GammaMgmtA = readit(26,1);
    inputs$GammaMgmtB = readit(26,2); 
  }else{
    inputs$GammaMgmtA = 0
    inputs$GammaMgmtB = 0
  }
  if(class(inputs$GammaMgmtA)!="numeric") stop("rav line 27: GammaMgmtA must be numeric.")
  if(class(inputs$GammaMgmtB)!="numeric") stop("rav line 27: GammaMgmtB must be numeric.")
  
  # LOWER AND UPPER ESCAPEMENT TEST LEVELS
  # The LOWER ESCAPEMENT LEVEL (ECrit) is the escapement level used by the
  #  program to test how often the observed escapements fall below this level.
  #  It may represent a "critical" level below which the spawner-recruit function
  #  destabilizes, and the stock increases risk of extinction, or it could be any 
  #  level one just wanted to monitor frequency of achieving less than or equal
  #  to that level.
  # The UPPER ECSAPEMENT LEVEL (ERecovery) is the escapement level used to compare
  #  against the geometric mean of the last n (EndAv) years of the run.  It may be a
  #  management escapement goal, an interim recovery level, or some other target level.
  inputs$ECrit = readit(27,1); # Lower escap threshold
  inputs$ERecovery = readit(28,1); # upper escap threshold
  inputs$EndAv = readit(28,2); # num yrs to ave for upper thresh calculation
  
  
  # ------------------ END OF FISHERY MANAGMENT INPUTS --------------------
  
  # INPUT STEP SIZE AND RANGE FOR TARGET EXPLOITATION RATES OR STARTING ESCAPEMENT
  # This program outputs information for a range of either exploitation rates or
  # starting escapement levels.
  # For VRAP 2.0, you specify the starting and ending ER and the step size.
  # This is a change from VRAP 1.0 which specified steps in terms of percentages of the base ER
  inputs$StepFunc = readit(29,1)
  inputs$StepFunc = toupper(inputs$StepFunc)
  if(!(inputs$StepFunc %in% c("POP", "ER"))) stop("rav line 30: Unknown selection. Must be ER or POP.")
  
  inputs$StepSize = readit(30,1)
  inputs$StepStart = readit(31,1) 
  inputs$StepEnd = readit(31,2)
  if(inputs$VRAPvrs==1){ #then we need to multiply by the TargetU or Pop
  #integer of the number of steps of ER or Pop Capacity to do  # is 1:BufMax
    buf = ifelse(inputs$StepFunc=="ER",inputs$TargetU,inputs$cap)
    inputs$StepSize = inputs$StepSize*buf
    inputs$StepStart = inputs$StepStart*buf
    inputs$StepEnd = inputs$StepEnd*buf
  }
  inputs$StepNum = round((inputs$StepEnd - inputs$StepStart) / inputs$StepSize + 1)

  # ------------------ END OF STEP DEFINITION SECTION --------------------
  
  # ----------------------- BASE STOCK DATA SECTION -----------------------------
  
  # begin dynamically keeping track of line number
  cline=37
  
  # INPUT INITIAL POPULATION SIZE BY AGE
  # The initial population size by age, for all ages, is used to seed the model.
  #  In year 1, the management actions are applied to this population, and a portion of
  #  each size class escapes.  By running the program over a range of starting population
  #  sizes, one can determine what minimum population size (or escapement) is needed
  #  to guarentee a probability of population viability.
  #  Although the input allows for different MaxAge from 5, the internal workings of the
  #  are fixed to 5 in many places.
  
  inputs$CohortStart = rep(0,inputs$MaxAge)
  for(Age in (inputs$MinAge - 1):inputs$MaxAge){
    inputs$CohortStart[Age] = readit(cline,1); cline=cline+1
  }
  
  # INPUT NATURAL MORTALITY RATES
  inputs$NatMort = rep(0,inputs$MaxAge)
  for(Age in (inputs$MinAge - 1):inputs$MaxAge){
    inputs$NatMort[Age] = readit(cline,1); cline=cline+1
  }    
  
  # INPUT MATURATION RATES BY AGE (AEQ will be calculated)
  inputs$MatRate = rep(0,inputs$MaxAge)
  for(Age in inputs$MinAge:inputs$MaxAge){
    inputs$MatRate[Age] = readit(cline,1); cline=cline+1
  }
  
  # INPUT PRETERMINAL AND MATURE EXPLOITATION RATES BY AGE
  # These will be used to proportion target ER by age and fishery
  #  by def, PTU and MatU are 0 before MinAge
  inputs$PTU = rep(0,inputs$MaxAge)
  inputs$MatU = rep(0,inputs$MaxAge)
  for(Age in inputs$MinAge:inputs$MaxAge){
    inputs$PTU[Age] = readit(cline,1); 
    inputs$MatU[Age] = readit(cline,2); cline=cline+1
  }
  return(inputs)
}