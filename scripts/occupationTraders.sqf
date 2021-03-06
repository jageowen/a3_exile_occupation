_logDetail = format['[OCCUPATION:Traders] starting @ %1',time]; 
[_logDetail] call SC_fnc_log;
{ 
    private _world              = _x select 0;
    
    if (worldName == _world) then
    {
        private _traderName 	    = _x select 1;
        private _traderPos 		    = _x select 2;
        private _fileName 		    = _x select 3;
        private _createSafezone 	= _x select 4;
        private _file = format ["x\addons\a3_exile_occupation\trader\%1",_fileName];
        SC_fnc_createTraders = compile preprocessFileLineNumbers _file; 
        [_traderPos] call SC_fnc_createTraders;

        _traderName setmarkeralpha 0; 
        private _marker = createMarker [ format [" %1 ", _traderName], _traderPos];
        _marker setMarkerText format ["%1", _traderName];
        _marker setMarkerSize  [3,3];
        _marker setMarkerShape "ICON";
        _marker setMarkerType "loc_Tree";
        _marker setMarkerColor "ColorBlack";
        _marker setMarkerBrush "Vertical";	
        
        if(_createSafezone) then
        {
            ExileTraderZoneMarkerPositions pushBack _traderPos;  
            ExileTraderZoneMarkerPositionsAndSize pushBack [_traderPos, 175];   
            publicVariable "ExileTraderZoneMarkerPositions";
            publicVariable "ExileTraderZoneMarkerPositionsAndSize";     
        };
        _logDetail = format['[OCCUPATION:Traders] Created trader base %1 @ %2',_traderName,_traderPos];
        [_logDetail] call SC_fnc_log;
        

        // Place the traders randomly

        private _traders = [
            ["Exile_Trader_AircraftCustoms",    "Exile_Sign_AircraftCustoms",       "GreekHead_A3_08",  "HubStandingUC_idle1"],
            ["Exile_Trader_Aircraft",           "Exile_Sign_Aircraft",              "WhiteHead_10",     "HubStandingUC_idle2"],
            ["Exile_Trader_Armory",             "Exile_Sign_Armory",                "WhiteHead_01",     "HubStandingUC_idle3"],
            ["Exile_Trader_Hardware",           "Exile_Sign_Hardware",              "WhiteHead_14",     "HubStandingUC_idle1"],
            ["Exile_Trader_Vehicle",            "Exile_Sign_Vehicles",              "AfricanHead_03",   "HubStandingUC_idle2"],
            ["Exile_Trader_VehicleCustoms",     "Exile_Sign_VehicleCustoms",        "GreekHead_A3_05",  "HubStandingUC_idle3"],
            ["Exile_Trader_WasteDump",          "Exile_Sign_WasteDump",             "WhiteHead_07",     "HubStandingUC_idle2"],
            ["Exile_Trader_Food",               "Exile_Sign_Food",                  "WhiteHead_15",     "HubStandingUC_idle3"],
            ["Exile_Trader_SpecialOperations",  "Exile_Sign_SpecialOperations",     "WhiteHead_06",     "HubStandingUC_idle1"],
            ["Exile_Trader_Equipment",          "Exile_Sign_Equipment",             "WhiteHead_15",     "HubStandingUC_idle2"],
            ["Exile_Trader_Office",             "Exile_Sign_Office",                "WhiteHead_10",     "HubStandingUC_idle1"]
        ];
        private _group = createGroup SC_SurvivorSide;
        _group setCombatMode "BLUE";
        _group setVariable ["DMS_AllowFreezing",false,true];
        _group setVariable ["DMS_LockLocality",true];
        _group setVariable ["DMS_SpawnedGroup",false];
        _group setVariable ["DMS_Group_Side", "survivor"];   


        enableSentences false;
        enableRadio false;
        {         
            private _traderType         = _x select 0;
            private _traderSign         = _x select 1;
            private _traderFace         = _x select 2;
            private _traderAnimation    = _x select 3;
            

            // Find nearest relevant sign for the trader
            private _nearestSign = nearestObject [_traderPos, _traderSign];
            private _signDir = getDir _nearestSign;
            _nearestSign setDir _signDir;            
            private _traderPosition = position _nearestSign;

            _traderType createUnit [_traderPosition, _group, "trader = this;"];
            trader disableAI "FSM";    
            trader disableAI "MOVE";                                                   
            trader disableAI "TARGET";
            trader disableAI "AUTOTARGET";
            trader disableAI "AUTOCOMBAT";
            trader disableAI "COVER";  
            trader disableAI "SUPPRESSION"; 
            trader reveal _nearestSign;
            _nearestSign disableCollisionWith trader;         
            trader disableCollisionWith _nearestSign; 
            trader attachTo [_nearestSign, [0, -2, -0.6]];
            detach trader;
            private _traderDirection = _signDir-180;
            trader setDir _traderDirection;
            
            trader setVariable ["ExileTraderType", _traderType,true];
            trader allowDamage false; 
            removeGoggles trader;
            removeBackpack trader;
            removeVest trader;
            removeHeadgear trader;
            private _loadOut = ["bandit"] call SC_fnc_selectGear;      
            trader forceAddUniform (_loadOut select 8);
            trader addVest (_loadOut select 9);
            trader addBackpack (_loadOut select 10);
            trader addHeadgear "H_Cap_blk";
            //trader setCaptive true;
            //trader switchMove _traderAnimation;
            sleep 0.2;
            diag_log format["[OCCUPATION:Traders] Created %1 with head %2 at %3 facing %4", _x select 0, _x select 2, _traderPosition, _traderDirection];
        } forEach _traders;                   
    }; 
} foreach SC_occupyTraderDetails;