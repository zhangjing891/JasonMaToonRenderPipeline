float3 UTS_MainLight(LightLoopContext lightLoopContext, FragInputs input, int mainLightIndex, out float inverseClipping)
{

    uint2 tileIndex = uint2(input.positionSS.xy) / GetTileSize();
    inverseClipping = 0;
    // input.positionSS is SV_Position
    PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, tileIndex);


    #ifdef VARYINGS_NEED_POSITION_WS
        float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
    #else
        // Unused
        float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0
    #endif

    SurfaceData surfaceData;
    BuiltinData builtinData;
    GetSurfaceAndBuiltinData(input, V, posInput, surfaceData, builtinData);

    BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);

    PreLightData preLightData = GetPreLightData(V, posInput, bsdfData);
    /* todo. these should be put int a struct */
    float4 Set_UV0 = input.texCoord0;
    float3x3 tangentTransform = input.tangentToWorld;
    //UnpackNormalmapRGorAG(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, texCoords))
    float4 n = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, Set_UV0); // todo. TRANSFORM_TEX
    //    float3 _NormalMap_var = UnpackNormalScale(tex2D(_NormalMap, TRANSFORM_TEX(Set_UV0, _NormalMap)), _BumpScale);
    float3 _NormalMap_var = UnpackNormalScale(n, _BumpScale);
    float3 normalLocal = _NormalMap_var.rgb;
    float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals

    float4 _MainTex_var = tex2D(_MainTex, TRANSFORM_TEX(Set_UV0, _MainTex));
    float3 i_normalDir = surfaceData.normalWS;
    float3 viewDirection = V;
    /* to here todo. these should be put int a struct */

    //v.2.0.4
    #if defined(_IS_CLIPPING_MODE) 
        //DoubleShadeWithFeather_Clipping
        float4 _ClippingMask_var = tex2D(_ClippingMask, TRANSFORM_TEX(Set_UV0, _ClippingMask));
        float Set_Clipping = saturate((lerp(_ClippingMask_var.r, (1.0 - _ClippingMask_var.r), _Inverse_Clipping) + _Clipping_Level));
        clip(Set_Clipping - 0.5);
    #elif defined(_IS_CLIPPING_TRANSMODE) || defined(_IS_TRANSCLIPPING_ON)
        //DoubleShadeWithFeather_TransClipping
        float4 _ClippingMask_var = tex2D(_ClippingMask, TRANSFORM_TEX(Set_UV0, _ClippingMask));
        float Set_MainTexAlpha = _MainTex_var.a;
        float _IsBaseMapAlphaAsClippingMask_var = lerp(_ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask);
        float _Inverse_Clipping_var = lerp(_IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping);
        float Set_Clipping = saturate((_Inverse_Clipping_var + _Clipping_Level));
        clip(Set_Clipping - 0.5);
        inverseClipping = _Inverse_Clipping_var;
    #elif defined(_IS_CLIPPING_OFF) || defined(_IS_TRANSCLIPPING_OFF)
        //DoubleShadeWithFeather
    #endif

    float shadowAttenuation = lightLoopContext.shadowValue;


    float3 mainLihgtDirection = -_DirectionalLightDatas[mainLightIndex].forward;
    float3 mainLightColor = _DirectionalLightDatas[mainLightIndex].color * GetCurrentExposureMultiplier() * _LightIntensity;
    //    float4 tmpColor = EvaluateLight_Directional(context, posInput, _DirectionalLightDatas[mainLightIndex]);
    //    float3 mainLightColor = tmpColor.xyz;
    float3 defaultLightDirection = normalize(UNITY_MATRIX_V[2].xyz + UNITY_MATRIX_V[1].xyz);
    float3 defaultLightColor = saturate(max(float3(0.05, 0.05, 0.05) * _Unlit_Intensity, max(ShadeSH9(float4(0.0, 0.0, 0.0, 1.0)), ShadeSH9(float4(0.0, -1.0, 0.0, 1.0)).rgb) * _Unlit_Intensity));
    float3 customLightDirection = normalize(mul(UNITY_MATRIX_M, float4(((float3(1.0, 0.0, 0.0) * _Offset_X_Axis_BLD * 10) + (float3(0.0, 1.0, 0.0) * _Offset_Y_Axis_BLD * 10) + (float3(0.0, 0.0, -1.0) * lerp(-1.0, 1.0, _Inverse_Z_Axis_BLD))), 0)).xyz);
    float3 lightDirection = normalize(lerp(defaultLightDirection, mainLihgtDirection.xyz, any(mainLihgtDirection.xyz)));
    lightDirection = lerp(lightDirection, customLightDirection, _Is_BLD);
    float3 originalLightColor = mainLightColor;

    float3 lightColor = lerp(max(defaultLightColor, originalLightColor), max(defaultLightColor, saturate(originalLightColor)), _Is_Filter_LightColor);


    ////// Lighting:
    float3 halfDirection = normalize(viewDirection + lightDirection);
    //v.2.0.5
    _Color = _BaseColor;
    float3 Set_LightColor = lightColor.rgb;
    float3 Set_BaseColor = lerp((_MainTex_var.rgb * _BaseColor.rgb), ((_MainTex_var.rgb * _BaseColor.rgb) * Set_LightColor), _Is_LightColor_Base);
    #ifdef UTS_LAYER_VISIBILITY
        float4 overridingColor = lerp(_BaseColorMaskColor, float4(_BaseColorMaskColor.w, 0.0f, 0.0f, 1.0f), _ComposerMaskMode);
        float  maskEnabled = max(_BaseColorOverridden, _ComposerMaskMode);
        Set_BaseColor = lerp(Set_BaseColor, overridingColor, maskEnabled);
        Set_BaseColor *= _BaseColorVisible;
    #endif //#ifdef UTS_LAYER_VISIBILITY
    //v.2.0.5
    float4 _1st_ShadeMap_var = lerp(tex2D(_1st_ShadeMap, TRANSFORM_TEX(Set_UV0, _1st_ShadeMap)), _MainTex_var, _Use_BaseAs1st);
    float3 Set_1st_ShadeColor = lerp((_1st_ShadeColor.rgb * _1st_ShadeMap_var.rgb), ((_1st_ShadeColor.rgb * _1st_ShadeMap_var.rgb) * Set_LightColor), _Is_LightColor_1st_Shade);
    #ifdef UTS_LAYER_VISIBILITY
        {
            float4 overridingColor = lerp(_FirstShadeMaskColor, float4(_FirstShadeMaskColor.w, 0.0f, 0.0f, 1.0f), _ComposerMaskMode);
            float  maskEnabled = max(_FirstShadeOverridden, _ComposerMaskMode);
            Set_1st_ShadeColor = lerp(Set_1st_ShadeColor, overridingColor, maskEnabled);
            Set_1st_ShadeColor = lerp(Set_1st_ShadeColor, Set_BaseColor, 1.0f - _FirstShadeVisible);
        }
    #endif //#ifdef UTS_LAYER_VISIBILITY
    //v.2.0.5
    float4 _2nd_ShadeMap_var = lerp(tex2D(_2nd_ShadeMap, TRANSFORM_TEX(Set_UV0, _2nd_ShadeMap)), _1st_ShadeMap_var, _Use_1stAs2nd);
    float3 Set_2nd_ShadeColor = lerp((_2nd_ShadeColor.rgb * _2nd_ShadeMap_var.rgb), ((_2nd_ShadeColor.rgb * _2nd_ShadeMap_var.rgb) * Set_LightColor), _Is_LightColor_2nd_Shade);
    float _HalfLambert_var = 0.5 * dot(lerp(i_normalDir, normalDirection, _Is_NormalMapToBase), lightDirection) + 0.5;
    float4 _Set_2nd_ShadePosition_var = tex2D(_Set_2nd_ShadePosition, TRANSFORM_TEX(Set_UV0, _Set_2nd_ShadePosition));
    float4 _Set_1st_ShadePosition_var = tex2D(_Set_1st_ShadePosition, TRANSFORM_TEX(Set_UV0, _Set_1st_ShadePosition));

    float _1stColorFeatherForMask = lerp(_BaseShade_Feather, 0.0f, max(_FirstShadeOverridden, _ComposerMaskMode));
    float _2ndColorFeatherForMask = lerp(_1st2nd_Shades_Feather, 0.0f, max(_SecondShadeOverridden, _ComposerMaskMode));


    float hairShadow = 1.0;
    #ifdef JTRP_FACE_SHADER
        GetJTRPHairShadow(hairShadow, posInput, lightDirection);        //头发阴影
    #endif
    //v.2.0.6
    //Minmimum value is same as the Minimum Feather's value with the Minimum Step's value as threshold.
    float _SystemShadowsLevel_var = (shadowAttenuation * 0.5) + 0.5 + _Tweak_SystemShadowsLevel > 0.001 ? (shadowAttenuation * 0.5) + 0.5 + _Tweak_SystemShadowsLevel : 0.0001;
    
    //ShadowMask
    float Set_FinalShadowMask = saturate(
    (
    1.0 + 
    ((lerp(_HalfLambert_var, 
    _HalfLambert_var * saturate(_SystemShadowsLevel_var),
    _Set_SystemShadowsToBase) * hairShadow 
    - 
    (_BaseColor_Step - _1stColorFeatherForMask)) 
    * ((1.0 - _Set_1st_ShadePosition_var.rgb).r - 1.0)) 
    / (_BaseColor_Step - (_BaseColor_Step - _1stColorFeatherForMask))
    )
    );
    
    // return Set_FinalShadowMask;
    //
    //Composition: 3 Basic Colors as Set_FinalBaseColor
    #ifdef UTS_LAYER_VISIBILITY
        {
            float4 overridingColor = lerp(_SecondShadeMaskColor, float4(_SecondShadeMaskColor.w, 0.0f, 0.0f, 1.0f), _ComposerMaskMode);
            float  maskEnabled = max(_SecondShadeOverridden, _ComposerMaskMode);
            Set_2nd_ShadeColor = lerp(Set_2nd_ShadeColor, overridingColor, maskEnabled);
            Set_2nd_ShadeColor = lerp(Set_2nd_ShadeColor, Set_BaseColor, 1.0f - _SecondShadeVisible);
        }
    #endif //#ifdef UTS_LAYER_VISIBILITY
    float3 Set_FinalBaseColor = lerp(Set_BaseColor, lerp(Set_1st_ShadeColor, Set_2nd_ShadeColor, saturate((1.0 + ((_HalfLambert_var - (_ShadeColor_Step - _2ndColorFeatherForMask)) * ((1.0 - _Set_2nd_ShadePosition_var.rgb).r - 1.0)) / (_ShadeColor_Step - (_ShadeColor_Step - _2ndColorFeatherForMask))))), Set_FinalShadowMask); // Final Color

    float4 _Set_HighColorMask_var = tex2D(_Set_HighColorMask, TRANSFORM_TEX(Set_UV0, _Set_HighColorMask));
    float _Specular_var = 0.5 * dot(halfDirection, lerp(i_normalDir, normalDirection, _Is_NormalMapToHighColor)) + 0.5; //  Specular                
    float _TweakHighColorMask_var = (saturate((_Set_HighColorMask_var.g + _Tweak_HighColorMaskLevel)) * lerp((1.0 - step(_Specular_var, (1.0 - pow(_HighColor_Power, 5)))), pow(_Specular_var, exp2(lerp(11, 1, _HighColor_Power))), _Is_SpecularToHighColor));
    float4 _HighColor_Tex_var = tex2D(_HighColor_Tex, TRANSFORM_TEX(Set_UV0, _HighColor_Tex));
    float3 _HighColor_var = (lerp((_HighColor_Tex_var.rgb * _HighColor.rgb), ((_HighColor_Tex_var.rgb * _HighColor.rgb) * Set_LightColor), _Is_LightColor_HighColor) * _TweakHighColorMask_var);


    //Composition: 3 Basic Colors and HighColor as Set_HighColor
    #ifdef UTS_LAYER_VISIBILITY
        float3 Set_HighColor;
        {
            float4 overridingColor = lerp(_HighlightMaskColor, float4(_HighlightMaskColor.w, 0.0f, 0.0f, 1.0f), _ComposerMaskMode);
            float  maskEnabled = max(_HighlightOverridden, _ComposerMaskMode);

            _HighColor_var *= _HighlightVisible;
            Set_HighColor =
            lerp(saturate(Set_FinalBaseColor - _TweakHighColorMask_var), Set_FinalBaseColor,
            lerp(_Is_BlendAddToHiColor, 1.0
            , _Is_SpecularToHighColor));
            float3 addColor =
            lerp(_HighColor_var, (_HighColor_var * ((1.0 - Set_FinalShadowMask) + (Set_FinalShadowMask * _TweakHighColorOnShadow)))
            , _Is_UseTweakHighColorOnShadow);
            Set_HighColor += addColor;
            if (any(addColor))
            {
                Set_HighColor = lerp(Set_HighColor, overridingColor, maskEnabled);
            }
        }

    #else
        float3 Set_HighColor = (lerp(saturate((Set_FinalBaseColor - _TweakHighColorMask_var)), Set_FinalBaseColor, lerp(_Is_BlendAddToHiColor, 1.0, _Is_SpecularToHighColor)) + lerp(_HighColor_var, (_HighColor_var * ((1.0 - Set_FinalShadowMask) + (Set_FinalShadowMask * _TweakHighColorOnShadow))), _Is_UseTweakHighColorOnShadow));
    #endif

    float4 _Set_RimLightMask_var = tex2D(_Set_RimLightMask, TRANSFORM_TEX(Set_UV0, _Set_RimLightMask));
    float3 _Is_LightColor_RimLight_var = lerp(_RimLightColor.rgb, (_RimLightColor.rgb * Set_LightColor), _Is_LightColor_RimLight);         //_Is_LightColor_RimLight灯光颜色是否影响RimLight
    float _RimArea_var = (1.0 - dot(lerp(i_normalDir, normalDirection, _Is_NormalMapToRimLight), viewDirection));
    // return _RimArea_var;
    float _RimLightPower_var = pow(_RimArea_var, exp2(lerp(3, 0, _RimLight_Power)));
    float _Rimlight_InsideMask_var = saturate(lerp((0.0 + ((_RimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0)) / (1.0 - _RimLight_InsideMask)), 
    step(_RimLight_InsideMask, _RimLightPower_var),
    _RimLight_FeatherOff));     //_RimLight_FeatherOff是否羽化Rim
    float _VertHalfLambert_var = 0.5 * dot(i_normalDir, lightDirection) + 0.5;
    float3 _LightDirection_MaskOn_var = lerp((_Is_LightColor_RimLight_var * _Rimlight_InsideMask_var), 
    (_Is_LightColor_RimLight_var * saturate((_Rimlight_InsideMask_var - ((1.0 - _VertHalfLambert_var) + _Tweak_LightDirection_MaskLevel)))),        //_Tweak_LightDirection_MaskLevel亮面这招影响程度
    _LightDirection_MaskOn);        //_LightDirection_MaskOn是否只有亮面显示RimLight

    float _ApRimLightPower_var = pow(_RimArea_var, exp2(lerp(3, 0, _Ap_RimLight_Power)));
    #ifdef UTS_LAYER_VISIBILITY    
        // return 1; 
        float4 overridingRimColor = lerp(_RimLightMaskColor, float4(_RimLightMaskColor.w, 0.0f, 0.0f, 1.0f), _ComposerMaskMode);        //_ComposerMaskMode使用_RimLightMaskColor.w
        float  maskRimEnabled = max(_RimLightOverridden, _ComposerMaskMode);        //单独显示Rim
        // return maskRimEnabled;

        float3 Set_RimLight = (saturate((_Set_RimLightMask_var.g + _Tweak_RimLightMaskLevel)) *     //_Tweak_RimLightMaskLevel RimLight遮罩
        lerp(_LightDirection_MaskOn_var, 
        (_LightDirection_MaskOn_var + (lerp(_Ap_RimLightColor.rgb, (_Ap_RimLightColor.rgb * Set_LightColor), _Is_LightColor_Ap_RimLight) * saturate((lerp((0.0 + ((_ApRimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0)) / (1.0 - _RimLight_InsideMask)), 
        step(_RimLight_InsideMask, _ApRimLightPower_var), _Ap_RimLight_FeatherOff) - (saturate(_VertHalfLambert_var) + _Tweak_LightDirection_MaskLevel))))), 
        _Add_Antipodean_RimLight));     //_Add_Antipodean_RimLight是否暗面补光
        // return float4(Set_RimLight,1);
        Set_RimLight *= _RimLightVisible;
        // return overridingRimColor;
        float3 _RimLight_var = lerp(Set_HighColor, (Set_HighColor + Set_RimLight), _RimLight);
        // return float4(Set_RimLight,1);
        // return _Add_Antipodean_RimLight;
        // _RimLight_var = 0.3;
        if (any(Set_RimLight) * maskRimEnabled)
        {
            _RimLight_var = overridingRimColor;         //单独显示Rim
            // _RimLight_var = float3(0.5,0.5,0.5);
        }
        // return float4(_RimLight_var,1);
    #else
        // return 0;
        float3 Set_RimLight = (saturate((_Set_RimLightMask_var.g + _Tweak_RimLightMaskLevel)) * lerp(_LightDirection_MaskOn_var, (_LightDirection_MaskOn_var + (lerp(_Ap_RimLightColor.rgb, (_Ap_RimLightColor.rgb * Set_LightColor), _Is_LightColor_Ap_RimLight) * saturate((lerp((0.0 + ((_ApRimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0)) / (1.0 - _RimLight_InsideMask)), step(_RimLight_InsideMask, _ApRimLightPower_var), _Ap_RimLight_FeatherOff) - (saturate(_VertHalfLambert_var) + _Tweak_LightDirection_MaskLevel))))), _Add_Antipodean_RimLight));
        //Composition: HighColor and RimLight as _RimLight_var
        float3 _RimLight_var = lerp(Set_HighColor, (Set_HighColor + Set_RimLight), _RimLight);
        // _RimLight_var = float3(0.5,0.5,0.5);
        
    #endif
    //Matcap
    //v.2.0.6 : CameraRolling Stabilizer
    //���X�N���v�g����F_sign_Mirror = -1 �Ȃ�A���̒��Ɣ���.
    //v.2.0.7
    fixed _sign_Mirror = 0; //  todo. i.mirrorFlag;
    float3 _Camera_Right = UNITY_MATRIX_V[0].xyz;
    float3 _Camera_Front = UNITY_MATRIX_V[2].xyz;
    float3 _Up_Unit = float3(0, 1, 0);
    float3 _Right_Axis = cross(_Camera_Front, _Up_Unit);

    //���̒��Ȃ甽�].
    if (_sign_Mirror < 0) {
        _Right_Axis = -1 * _Right_Axis;
        _Rotate_MatCapUV = -1 * _Rotate_MatCapUV;
    }
    else {
        _Right_Axis = _Right_Axis;
    }
    float _Camera_Right_Magnitude = sqrt(_Camera_Right.x * _Camera_Right.x + _Camera_Right.y * _Camera_Right.y + _Camera_Right.z * _Camera_Right.z);
    float _Right_Axis_Magnitude = sqrt(_Right_Axis.x * _Right_Axis.x + _Right_Axis.y * _Right_Axis.y + _Right_Axis.z * _Right_Axis.z);
    float _Camera_Roll_Cos = dot(_Right_Axis, _Camera_Right) / (_Right_Axis_Magnitude * _Camera_Right_Magnitude);
    float _Camera_Roll = acos(clamp(_Camera_Roll_Cos, -1, 1));
    fixed _Camera_Dir = _Camera_Right.y < 0 ? -1 : 1;
    float _Rot_MatCapUV_var_ang = (_Rotate_MatCapUV * 3.141592654) - _Camera_Dir * _Camera_Roll * _CameraRolling_Stabilizer;
    //v.2.0.7
    float2 _Rot_MatCapNmUV_var = RotateUV(Set_UV0, (_Rotate_NormalMapForMatCapUV * 3.141592654), float2(0.5, 0.5), 1.0);
    //V.2.0.6
    float3 _NormalMapForMatCap_var = UnpackNormalScale(tex2D(_NormalMapForMatCap, TRANSFORM_TEX(_Rot_MatCapNmUV_var, _NormalMapForMatCap)), _BumpScaleMatcap);
    //v.2.0.5: MatCap with camera skew correction
    float3 viewNormal = (mul(UNITY_MATRIX_V, float4(lerp(i_normalDir, mul(_NormalMapForMatCap_var.rgb, tangentTransform).rgb, _Is_NormalMapForMatCap), 0))).rgb;
    float3 NormalBlend_MatcapUV_Detail = viewNormal.rgb * float3(-1, -1, 1);
    float3 NormalBlend_MatcapUV_Base = (mul(UNITY_MATRIX_V, float4(viewDirection, 0)).rgb * float3(-1, -1, 1)) + float3(0, 0, 1);
    float3 noSknewViewNormal = NormalBlend_MatcapUV_Base * dot(NormalBlend_MatcapUV_Base, NormalBlend_MatcapUV_Detail) / NormalBlend_MatcapUV_Base.b - NormalBlend_MatcapUV_Detail;
    float2 _ViewNormalAsMatCapUV = (lerp(noSknewViewNormal, viewNormal, _Is_Ortho).rg * 0.5) + 0.5;
    //v.2.0.7
    float2 _Rot_MatCapUV_var = RotateUV((0.0 + ((_ViewNormalAsMatCapUV - (0.0 + _Tweak_MatCapUV)) * (1.0 - 0.0)) / ((1.0 - _Tweak_MatCapUV) - (0.0 + _Tweak_MatCapUV))), _Rot_MatCapUV_var_ang, float2(0.5, 0.5), 1.0);
    //���̒��Ȃ�UV���E���].
    if (_sign_Mirror < 0) {
        _Rot_MatCapUV_var.x = 1 - _Rot_MatCapUV_var.x;
    }
    else {
        _Rot_MatCapUV_var = _Rot_MatCapUV_var;
    }
    //v.2.0.6 : LOD of Matcap
    float4 _MatCap_Sampler_var = tex2Dlod(_MatCap_Sampler, float4(TRANSFORM_TEX(_Rot_MatCapUV_var, _MatCap_Sampler), 0.0, _BlurLevelMatcap));
    //
    //MatcapMask
    float4 _Set_MatcapMask_var = tex2D(_Set_MatcapMask, TRANSFORM_TEX(Set_UV0, _Set_MatcapMask));
    float _Tweak_MatcapMaskLevel_var = saturate(lerp(_Set_MatcapMask_var.g, (1.0 - _Set_MatcapMask_var.g), _Inverse_MatcapMask) + _Tweak_MatcapMaskLevel);
    //
    float3 _Is_LightColor_MatCap_var = lerp((_MatCap_Sampler_var.rgb * _MatCapColor.rgb), ((_MatCap_Sampler_var.rgb * _MatCapColor.rgb) * Set_LightColor), _Is_LightColor_MatCap);
    //v.2.0.6 : ShadowMask on Matcap in Blend mode : multiply
    float3 Set_MatCap = lerp(_Is_LightColor_MatCap_var, (_Is_LightColor_MatCap_var * ((1.0 - Set_FinalShadowMask) + (Set_FinalShadowMask * _TweakMatCapOnShadow)) + lerp(Set_HighColor * Set_FinalShadowMask * (1.0 - _TweakMatCapOnShadow), float3(0.0, 0.0, 0.0), _Is_BlendAddToMatCap)), _Is_UseTweakMatCapOnShadow);

    //
    //Composition: RimLight and MatCap as finalColor
    //Broke down finalColor composition
    float3 matCapColorOnAddMode = _RimLight_var + Set_MatCap * _Tweak_MatcapMaskLevel_var;
    float _Tweak_MatcapMaskLevel_var_MultiplyMode = _Tweak_MatcapMaskLevel_var * lerp(1.0, (1.0 - (Set_FinalShadowMask) * (1.0 - _TweakMatCapOnShadow)), _Is_UseTweakMatCapOnShadow);
    float3 matCapColorOnMultiplyMode = Set_HighColor * (1 - _Tweak_MatcapMaskLevel_var_MultiplyMode) + Set_HighColor * Set_MatCap * _Tweak_MatcapMaskLevel_var_MultiplyMode + lerp(float3(0, 0, 0), Set_RimLight, _RimLight);
    float3 matCapColorFinal = lerp(matCapColorOnMultiplyMode, matCapColorOnAddMode, _Is_BlendAddToMatCap);
    
    float3 finalColor = lerp(_RimLight_var, matCapColorFinal, _MatCap);// Final Composition before Emissive
    // return 1;


    //===============================================
    //                    JTRP
    //===============================================
    GetTangentHighLight(finalColor, input.tangentToWorld, input.positionRWS, V, input.texCoord0.xy, input.texCoord1.xy, 1 - Set_FinalShadowMask);

    GetSSRimLight(finalColor, posInput, Set_UV0, lightDirection, normalDirection, Set_FinalShadowMask);

    //
    //v.2.0.6: GI_Intensity with Intensity Multiplier Filter

    //    outColor = float4(Set_HighColor, 1);
    //     outColor = _MainTex_var;

    return finalColor;
}
