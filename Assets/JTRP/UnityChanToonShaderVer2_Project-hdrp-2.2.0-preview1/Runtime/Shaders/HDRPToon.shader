//Unitychan Toon Shader ver.1.0
//v.1.0.0
//nobuyuki@unity3d.com
//toshiyuki@unity3d.com (Universal RP/HDRP)
Shader "HDRP/Toon"
{
	Properties
	{
		// Versioning of material to help for upgrading

		[HideInInspector] _utsVersionX ("VersionX", Float) = 1
		[HideInInspector] _utsVersionY ("VersionY", Float) = 0
		[HideInInspector] _utsVersionZ ("VersionZ", Float) = 0
		// Following set of parameters represent the parameters node inside the MaterialGraph.
		// They are use to fill a SurfaceData. With a MaterialGraph this should not exist.

		// Reminder. Color here are in linear but the UI (color picker) do the conversion sRGB to linear
		_BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
		_BaseColorMap ("BaseColorMap", 2D) = "white" { }
		[HideInInspector] _BaseColorMap_MipInfo ("_BaseColorMap_MipInfo", Vector) = (0, 0, 0, 0)

		_Metallic ("_Metallic", Range(0.0, 1.0)) = 0
		_Smoothness ("Smoothness", Range(0.0, 1.0)) = 0.5
		_MaskMap ("MaskMap", 2D) = "white" { }
		_SmoothnessRemapMin ("SmoothnessRemapMin", Float) = 0.0
		_SmoothnessRemapMax ("SmoothnessRemapMax", Float) = 1.0
		_AORemapMin ("AORemapMin", Float) = 0.0
		_AORemapMax ("AORemapMax", Float) = 1.0

		_NormalMap ("NormalMap", 2D) = "bump" { } // Tangent space normal map
		_NormalMapOS ("NormalMapOS", 2D) = "white" { }// Object space normal map - no good default value
		_NormalScale ("_NormalScale", Range(0.0, 8.0)) = 1

		_BentNormalMap ("_BentNormalMap", 2D) = "bump" { }
		_BentNormalMapOS ("_BentNormalMapOS", 2D) = "white" { }

		_HeightMap ("HeightMap", 2D) = "black" { }
		// Caution: Default value of _HeightAmplitude must be (_HeightMax - _HeightMin) * 0.01
		// Those two properties are computed from the ones exposed in the UI and depends on the displaement mode so they are separate because we don't want to lose information upon displacement mode change.
		[HideInInspector] _HeightAmplitude ("Height Amplitude", Float) = 0.02 // In world units. This will be computed in the UI.
		[HideInInspector] _HeightCenter ("Height Center", Range(0.0, 1.0)) = 0.5 // In texture space

		[Enum(MinMax, 0, Amplitude, 1)] _HeightMapParametrization ("Heightmap Parametrization", Int) = 0
		// These parameters are for vertex displacement/Tessellation
		_HeightOffset ("Height Offset", Float) = 0
		// MinMax mode
		_HeightMin ("Heightmap Min", Float) = -1
		_HeightMax ("Heightmap Max", Float) = 1
		// Amplitude mode
		_HeightTessAmplitude ("Amplitude", Float) = 2.0 // in Centimeters
		_HeightTessCenter ("Height Center", Range(0.0, 1.0)) = 0.5 // In texture space

		// These parameters are for pixel displacement
		_HeightPoMAmplitude ("Height Amplitude", Float) = 2.0 // In centimeters

		_DetailMap ("DetailMap", 2D) = "linearGrey" { }
		_DetailAlbedoScale ("_DetailAlbedoScale", Range(0.0, 2.0)) = 1
		_DetailNormalScale ("_DetailNormalScale", Range(0.0, 2.0)) = 1
		_DetailSmoothnessScale ("_DetailSmoothnessScale", Range(0.0, 2.0)) = 1

		_TangentMap ("TangentMap", 2D) = "bump" { }
		_TangentMapOS ("TangentMapOS", 2D) = "white" { }
		_Anisotropy ("Anisotropy", Range(-1.0, 1.0)) = 0
		_AnisotropyMap ("AnisotropyMap", 2D) = "white" { }

		_SubsurfaceMask ("Subsurface Radius", Range(0.0, 1.0)) = 1.0
		_SubsurfaceMaskMap ("Subsurface Radius Map", 2D) = "white" { }
		_Thickness ("Thickness", Range(0.0, 1.0)) = 1.0
		_ThicknessMap ("Thickness Map", 2D) = "white" { }
		_ThicknessRemap ("Thickness Remap", Vector) = (0, 1, 0, 0)

		_IridescenceThickness ("Iridescence Thickness", Range(0.0, 1.0)) = 1.0
		_IridescenceThicknessMap ("Iridescence Thickness Map", 2D) = "white" { }
		_IridescenceThicknessRemap ("Iridescence Thickness Remap", Vector) = (0, 1, 0, 0)
		_IridescenceMask ("Iridescence Mask", Range(0.0, 1.0)) = 1.0
		_IridescenceMaskMap ("Iridescence Mask Map", 2D) = "white" { }

		_CoatMask ("Coat Mask", Range(0.0, 1.0)) = 0.0
		_CoatMaskMap ("CoatMaskMap", 2D) = "white" { }

		[ToggleUI] _EnergyConservingSpecularColor ("_EnergyConservingSpecularColor", Float) = 1.0
		_SpecularColor ("SpecularColor", Color) = (1, 1, 1, 1)
		_SpecularColorMap ("SpecularColorMap", 2D) = "white" { }

		// Following options are for the GUI inspector and different from the input parameters above
		// These option below will cause different compilation flag.
		[Enum(Off, 0, From Ambient Occlusion, 1, From Bent Normals, 2)]  _SpecularOcclusionMode ("Specular Occlusion Mode", Int) = 1

		[HDR] _EmissiveColor ("EmissiveColor", Color) = (0, 0, 0)
		// Used only to serialize the LDR and HDR emissive color in the material UI,
		// in the shader only the _EmissiveColor should be used
		[HideInInspector] _EmissiveColorLDR ("EmissiveColor LDR", Color) = (0, 0, 0)
		_EmissiveColorMap ("EmissiveColorMap", 2D) = "white" { }
		[ToggleUI] _AlbedoAffectEmissive ("Albedo Affect Emissive", Float) = 0.0
		[HideInInspector] _EmissiveIntensityUnit ("Emissive Mode", Int) = 0
		[ToggleUI] _UseEmissiveIntensity ("Use Emissive Intensity", Int) = 0
		_EmissiveIntensity ("Emissive Intensity", Float) = 1
		_EmissiveExposureWeight ("Emissive Pre Exposure", Range(0.0, 1.0)) = 1.0

		_DistortionVectorMap ("DistortionVectorMap", 2D) = "black" { }
		[ToggleUI] _DistortionEnable ("Enable Distortion", Float) = 0.0
		[ToggleUI] _DistortionDepthTest ("Distortion Depth Test Enable", Float) = 1.0
		[Enum(Add, 0, Multiply, 1, Replace, 2)] _DistortionBlendMode ("Distortion Blend Mode", Int) = 0
		[HideInInspector] _DistortionSrcBlend ("Distortion Blend Src", Int) = 0
		[HideInInspector] _DistortionDstBlend ("Distortion Blend Dst", Int) = 0
		[HideInInspector] _DistortionBlurSrcBlend ("Distortion Blur Blend Src", Int) = 0
		[HideInInspector] _DistortionBlurDstBlend ("Distortion Blur Blend Dst", Int) = 0
		[HideInInspector] _DistortionBlurBlendMode ("Distortion Blur Blend Mode", Int) = 0
		_DistortionScale ("Distortion Scale", Float) = 1
		_DistortionVectorScale ("Distortion Vector Scale", Float) = 2
		_DistortionVectorBias ("Distortion Vector Bias", Float) = -1
		_DistortionBlurScale ("Distortion Blur Scale", Float) = 1
		_DistortionBlurRemapMin ("DistortionBlurRemapMin", Float) = 0.0
		_DistortionBlurRemapMax ("DistortionBlurRemapMax", Float) = 1.0


		[ToggleUI]  _UseShadowThreshold ("_UseShadowThreshold", Float) = 0.0
		[ToggleUI]  _AlphaCutoffEnable ("Alpha Cutoff Enable", Float) = 0.0
		_AlphaCutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
		_AlphaCutoffShadow ("_AlphaCutoffShadow", Range(0.0, 1.0)) = 0.5
		_AlphaCutoffPrepass ("_AlphaCutoffPrepass", Range(0.0, 1.0)) = 0.5
		_AlphaCutoffPostpass ("_AlphaCutoffPostpass", Range(0.0, 1.0)) = 0.5
		[ToggleUI] _TransparentDepthPrepassEnable ("_TransparentDepthPrepassEnable", Float) = 0.0
		[ToggleUI] _TransparentBackfaceEnable ("_TransparentBackfaceEnable", Float) = 0.0
		[ToggleUI] _TransparentDepthPostpassEnable ("_TransparentDepthPostpassEnable", Float) = 0.0
		_TransparentSortPriority ("_TransparentSortPriority", Float) = 0

		// Transparency
		[Enum(None, 0, Box, 1, Sphere, 2, Thin, 3)]_RefractionModel ("Refraction Model", Int) = 0
		[Enum(Proxy, 1, HiZ, 2)]_SSRefractionProjectionModel ("Refraction Projection Model", Int) = 0
		_Ior ("Index Of Refraction", Range(1.0, 2.5)) = 1.5
		_TransmittanceColor ("Transmittance Color", Color) = (1.0, 1.0, 1.0)
		_TransmittanceColorMap ("TransmittanceColorMap", 2D) = "white" { }
		_ATDistance ("Transmittance Absorption Distance", Float) = 1.0
		[ToggleUI] _TransparentWritingMotionVec ("_TransparentWritingMotionVec", Float) = 0.0

		// Stencil state

		// Forward
		[HideInInspector] _StencilRef ("_StencilRef", Int) = 2 // StencilLightingUsage.RegularLighting
		[HideInInspector] _StencilWriteMask ("_StencilWriteMask", Int) = 3 // StencilMask.Lighting
		// GBuffer
		[HideInInspector] _StencilRefGBuffer ("_StencilRefGBuffer", Int) = 2 // StencilLightingUsage.RegularLighting
		[HideInInspector] _StencilWriteMaskGBuffer ("_StencilWriteMaskGBuffer", Int) = 3 // StencilMask.Lighting
		// Depth prepass
		[HideInInspector] _StencilRefDepth ("_StencilRefDepth", Int) = 0 // Nothing
		[HideInInspector] _StencilWriteMaskDepth ("_StencilWriteMaskDepth", Int) = 32 // DoesntReceiveSSR
		// Motion vector pass
		[HideInInspector] _StencilRefMV ("_StencilRefMV", Int) = 128 // StencilBitMask.ObjectMotionVectors
		[HideInInspector] _StencilWriteMaskMV ("_StencilWriteMaskMV", Int) = 128 // StencilBitMask.ObjectMotionVectors
		// Distortion vector pass
		[HideInInspector] _StencilRefDistortionVec ("_StencilRefDistortionVec", Int) = 64 // StencilBitMask.DistortionVectors
		[HideInInspector] _StencilWriteMaskDistortionVec ("_StencilWriteMaskDistortionVec", Int) = 64 // StencilBitMask.DistortionVectors

		// Blending state
		[HideInInspector] _SurfaceType ("__surfacetype", Float) = 0.0
		[HideInInspector] _BlendMode ("__blendmode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _AlphaSrcBlend ("__alphaSrc", Float) = 1.0
		[HideInInspector] _AlphaDstBlend ("__alphaDst", Float) = 0.0
		[HideInInspector][ToggleUI] _ZWrite ("__zw", Float) = 1.0
		// [HideInInspector] _CullMode ("__cullmode", Float) = 2.0
		[HideInInspector] _CullModeForward ("__cullmodeForward", Float) = 2.0 // This mode is dedicated to Forward to correctly handle backface then front face rendering thin transparent
		[Enum(UnityEditor.Rendering.HighDefinition.TransparentCullMode)] _TransparentCullMode ("_TransparentCullMode", Int) = 2 // Back culling by default
		[HideInInspector] _ZTestDepthEqualForOpaque ("_ZTestDepthEqualForOpaque", Int) = 4 // Less equal
		[HideInInspector] _ZTestModeDistortion ("_ZTestModeDistortion", Int) = 8
		[HideInInspector] _ZTestGBuffer ("_ZTestGBuffer", Int) = 4
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTestTransparent ("Transparent ZTest", Int) = 4 // Less equal

		[ToggleUI] _EnableFogOnTransparent ("Enable Fog", Float) = 1.0
		[ToggleUI] _EnableBlendModePreserveSpecularLighting ("Enable Blend Mode Preserve Specular Lighting", Float) = 1.0

		[ToggleUI] _DoubleSidedEnable ("Double sided enable", Float) = 0.0
		[Enum(Flip, 0, Mirror, 1, None, 2)] _DoubleSidedNormalMode ("Double sided normal mode", Float) = 1
		[HideInInspector] _DoubleSidedConstants ("_DoubleSidedConstants", Vector) = (1, 1, -1, 0)

		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3, Planar, 4, Triplanar, 5)] _UVBase ("UV Set for base", Float) = 0
		_TexWorldScale ("Scale to apply on world coordinate", Float) = 1.0
		[HideInInspector] _InvTilingScale ("Inverse tiling scale = 2 / (abs(_BaseColorMap_ST.x) + abs(_BaseColorMap_ST.y))", Float) = 1
		[HideInInspector] _UVMappingMask ("_UVMappingMask", Color) = (1, 0, 0, 0)
		[Enum(TangentSpace, 0, ObjectSpace, 1)] _NormalMapSpace ("NormalMap space", Float) = 0

		// Following enum should be material feature flags (i.e bitfield), however due to Gbuffer encoding constrain many combination exclude each other
		// so we use this enum as "material ID" which can be interpreted as preset of bitfield of material feature
		// The only material feature flag that can be added in all cases is clear coat
		[Enum(Subsurface Scattering, 0, Standard, 1, Anisotropy, 2, Iridescence, 3, Specular Color, 4, Translucent, 5)] _MaterialID ("MaterialId", Int) = 1 // MaterialId.Standard
		[ToggleUI] _TransmissionEnable ("_TransmissionEnable", Float) = 1.0

		[Enum(None, 0, Vertex displacement, 1, Pixel displacement, 2)] _DisplacementMode ("DisplacementMode", Int) = 0
		[ToggleUI] _DisplacementLockObjectScale ("displacement lock object scale", Float) = 1.0
		[ToggleUI] _DisplacementLockTilingScale ("displacement lock tiling scale", Float) = 1.0
		[ToggleUI] _DepthOffsetEnable ("Depth Offset View space", Float) = 0.0

		[ToggleUI] _EnableGeometricSpecularAA ("EnableGeometricSpecularAA", Float) = 0.0
		_SpecularAAScreenSpaceVariance ("SpecularAAScreenSpaceVariance", Range(0.0, 1.0)) = 0.1
		_SpecularAAThreshold ("SpecularAAThreshold", Range(0.0, 1.0)) = 0.2

		_PPDMinSamples ("Min sample for POM", Range(1.0, 64.0)) = 5
		_PPDMaxSamples ("Max sample for POM", Range(1.0, 64.0)) = 15
		_PPDLodThreshold ("Start lod to fade out the POM effect", Range(0.0, 16.0)) = 5
		_PPDPrimitiveLength ("Primitive length for POM", Float) = 1
		_PPDPrimitiveWidth ("Primitive width for POM", Float) = 1
		[HideInInspector] _InvPrimScale ("Inverse primitive scale for non-planar POM", Vector) = (1, 1, 0, 0)

		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _UVDetail ("UV Set for detail", Float) = 0
		[HideInInspector] _UVDetailsMappingMask ("_UVDetailsMappingMask", Color) = (1, 0, 0, 0)
		[ToggleUI] _LinkDetailsWithBase ("LinkDetailsWithBase", Float) = 1.0

		[Enum(Use Emissive Color, 0, Use Emissive Mask, 1)] _EmissiveColorMode ("Emissive color mode", Float) = 1
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3, Planar, 4, Triplanar, 5)] _UVEmissive ("UV Set for emissive", Float) = 0
		_TexWorldScaleEmissive ("Scale to apply on world coordinate", Float) = 1.0
		[HideInInspector] _UVMappingMaskEmissive ("_UVMappingMaskEmissive", Color) = (1, 0, 0, 0)

		// Caution: C# code in BaseLitUI.cs call LightmapEmissionFlagsProperty() which assume that there is an existing "_EmissionColor"
		// value that exist to identify if the GI emission need to be enabled.
		// In our case we don't use such a mechanism but need to keep the code quiet. We declare the value and always enable it.
		// TODO: Fix the code in legacy unity so we can customize the beahvior for GI
		_EmissionColor ("Color", Color) = (1, 1, 1)

		// HACK: GI Baking system relies on some properties existing in the shader ("_MainTex", "_Cutoff" and "_Color") for opacity handling, so we need to store our version of those parameters in the hard-coded name the GI baking system recognizes.
		_MainTex("Albedo", 2D) = "white" { }
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		[ToggleUI] _SupportDecals ("Support Decals", Float) = 1.0
		[ToggleUI] _ReceivesSSR ("Receives SSR", Float) = 1.0
		[ToggleUI] _AddPrecomputedVelocity ("AddPrecomputedVelocity", Float) = 0.0

		[HideInInspector] _DiffusionProfile ("Obsolete, kept for migration purpose", Int) = 0
		[HideInInspector] _DiffusionProfileAsset ("Diffusion Profile Asset", Vector) = (0, 0, 0, 0)
		[HideInInspector] _DiffusionProfileHash ("Diffusion Profile Hash", Float) = 0
		// -----------------------------------------------------------------------------
		// parameters for UTS
		// -----------------------------------------------------------------------------
		[HideInInspector] _simpleUI ("SimpleUI", Int) = 0
		[HideInInspector] _utsVersionX ("VersionX", Float) = 1
		[HideInInspector] _utsVersionY ("VersionY", Float) = 0
		[HideInInspector] _utsVersionZ ("VersionZ", Float) = 0

		[HideInInspector] _utsTechnique ("Technique", int) = 0 //DWF
		[HideInInspector] _AutoRenderQueue ("Automatic Render Queue ", int) = 1
		[Enum(OFF, 0, StencilOut, 1, StencilMask, 2)] _StencilMode ("StencilMode", int) = 0
		// these are set in UniversalToonGUI.cs in accordance with _StencilMode
		_StencilComp ("Stencil Comparison", Float) = 8
		_StencilNo ("Stencil No", Float) = 1
		_StencilOpPass ("Stencil Operation", Float) = 0
		_StencilOpFail ("Stencil Operation", Float) = 0
		[Enum(OFF, 0, ON, 1, )] _TransparentEnabled ("Transparent Mode", int) = 0

		// DoubleShadeWithFeather
		// 0:_IS_CLIPPING_OFF      1:_IS_CLIPPING_MODE    2:_IS_CLIPPING_TRANSMODE
		// ShadingGradeMap
		// 0:_IS_TRANSCLIPPING_OFF 1:_IS_TRANSCLIPPING_ON
		[Enum(OFF, 0, ON, 1, TRANSMODE, 2)] _ClippingMode ("CliippingMode", int) = 0

		[Enum(OFF, 0, FRONT, 1, BACK, 2)] _CullMode ("Cull Mode", int) = 2  //OFF/FRONT/BACK
		[Enum(OFF, 0, ONT, 1)]	_ZWriteMode ("ZWrite Mode", int) = 1  //OFF/ON
		[Enum(OFF, 0, ONT, 1)]	_ZOverDrawMode ("ZOver Draw Mode", Float) = 0  //OFF/ON
		_SPRDefaultUnlitColorMask ("SPRDefaultUnlit Path Color Mask", int) = 15
		[Enum(OFF, 0, FRONT, 1, BACK, 2)] _SRPDefaultUnlitColMode ("SPRDefaultUnlit  Cull Mode", int) = 1  //OFF/FRONT/BACK
		// ClippingMask paramaters from Here.
		_ClippingMask ("ClippingMask", 2D) = "white" { }
		//v.2.0.4
		[HideInInspector] _IsBaseMapAlphaAsClippingMask ("IsBaseMapAlphaAsClippingMask", Float) = 1
		//
		[Toggle(_)] _Inverse_Clipping ("Inverse_Clipping", Float) = 0
		_Clipping_Level ("Clipping_Level", Range(0, 1)) = 0
		_Tweak_transparency ("Tweak_transparency", Range(-1, 1)) = 0
		// ClippingMask paramaters to Here.

		//            _MainTex ("BaseMap", 2D) = "white" {}
		[HideInInspector] _BaseMap ("BaseMap", 2D) = "white" { }
		_BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
		//v.2.0.5 : Clipping/TransClipping for SSAO Problems in PostProcessing Stack.
		//If you want to go back the former SSAO results, comment out the below line.
		[HideInInspector] _Color ("Color", Color) = (1, 1, 1, 1)
		//
		[Toggle(_)] _Is_LightColor_Base ("Is_LightColor_Base", Float) = 1
		_1st_ShadeMap ("1st_ShadeMap", 2D) = "white" { }
		//v.2.0.5
		[Toggle(_)] _Use_BaseAs1st ("Use BaseMap as 1st_ShadeMap", Float) = 0
		_1st_ShadeColor ("1st_ShadeColor", Color) = (1, 1, 1, 1)
		[Toggle(_)] _Is_LightColor_1st_Shade ("Is_LightColor_1st_Shade", Float) = 1
		_2nd_ShadeMap ("2nd_ShadeMap", 2D) = "white" { }
		//v.2.0.5
		[Toggle(_)] _Use_1stAs2nd ("Use 1st_ShadeMap as 2nd_ShadeMap", Float) = 0
		_2nd_ShadeColor ("2nd_ShadeColor", Color) = (1, 1, 1, 1)
		[Toggle(_)] _Is_LightColor_2nd_Shade ("Is_LightColor_2nd_Shade", Float) = 1

		//            _NormalMap ("NormalMap", 2D) = "bump" {}
		_BumpScale ("Normal Scale", Range(0, 1)) = 1
		[Toggle(_)] _Is_NormalMapToBase ("Is_NormalMapToBase", Float) = 0
		//v.2.0.4.4
		[Toggle(_)] _Set_SystemShadowsToBase ("Set_SystemShadowsToBase", Float) = 1
		_Tweak_SystemShadowsLevel ("Tweak_SystemShadowsLevel", Range(-0.5, 0.5)) = 0
		//v.2.0.6
		_BaseColor_Step ("BaseColor_Step", Range(0, 1)) = 0.5
		_BaseShade_Feather ("Base/Shade_Feather", Range(0.0001, 1)) = 0.0001
		_ShadeColor_Step ("ShadeColor_Step", Range(0, 1)) = 0
		_1st2nd_Shades_Feather ("1st/2nd_Shades_Feather", Range(0.0001, 1)) = 0.0001
		[HideInInspector] _1st_ShadeColor_Step ("1st_ShadeColor_Step", Range(0, 1)) = 0.5
		[HideInInspector] _1st_ShadeColor_Feather ("1st_ShadeColor_Feather", Range(0.0001, 1)) = 0.0001
		[HideInInspector] _2nd_ShadeColor_Step ("2nd_ShadeColor_Step", Range(0, 1)) = 0
		[HideInInspector] _2nd_ShadeColor_Feather ("2nd_ShadeColor_Feather", Range(0.0001, 1)) = 0.0001
		//v.2.0.5
		_StepOffset ("Step_Offset (ForwardAdd Only)", Range(-0.5, 0.5)) = 0
		[Toggle(_)] _Is_Filter_HiCutPointLightColor ("PointLights HiCut_Filter (ForwardAdd Only)", Float) = 1
		//
		_Set_1st_ShadePosition ("Set_1st_ShadePosition", 2D) = "white" { }
		_Set_2nd_ShadePosition ("Set_2nd_ShadePosition", 2D) = "white" { }
		_ShadingGradeMap ("ShadingGradeMap", 2D) = "gray" { }
		//v.2.0.6
		_Tweak_ShadingGradeMapLevel ("Tweak_ShadingGradeMapLevel", Range(0, 1)) = 0
		_BlurLevelSGM ("Blur Level of ShadingGradeMap", Range(0, 10)) = 0

		//
		_HighColor ("HighColor", Color) = (0, 0, 0, 1)
		//v.2.0.4 HighColor_Tex
		_HighColor_Tex ("HighColor_Tex", 2D) = "white" { }
		[Toggle(_)] _Is_LightColor_HighColor ("Is_LightColor_HighColor", Float) = 1
		[Toggle(_)] _Is_NormalMapToHighColor ("Is_NormalMapToHighColor", Float) = 0
		_HighColor_Power ("HighColor_Power", Range(0, 1)) = 0
		[Toggle(_)] _Is_SpecularToHighColor ("Is_SpecularToHighColor", Float) = 0
		[Toggle(_)] _Is_BlendAddToHiColor ("Is_BlendAddToHiColor", Float) = 0
		[Toggle(_)] _Is_UseTweakHighColorOnShadow ("Is_UseTweakHighColorOnShadow", Float) = 0
		_TweakHighColorOnShadow ("TweakHighColorOnShadow", Range(0, 1)) = 0
	//�n�C�J���[�}�X�N.
	_Set_HighColorMask ("Set_HighColorMask", 2D) = "white" { }
	_Tweak_HighColorMaskLevel ("Tweak_HighColorMaskLevel", Range(-1, 1)) = 0
	[Toggle(_)] _RimLight ("RimLight", Float) = 0
	_RimLightColor ("RimLightColor", Color) = (1, 1, 1, 1)
	[Toggle(_)] _Is_LightColor_RimLight ("Is_LightColor_RimLight", Float) = 1
	[Toggle(_)] _Is_NormalMapToRimLight ("Is_NormalMapToRimLight", Float) = 0
	_RimLight_Power ("RimLight_Power", Range(0, 1)) = 0.1
	_RimLight_InsideMask ("RimLight_InsideMask", Range(0.0001, 1)) = 0.0001
	[Toggle(_)] _RimLight_FeatherOff ("RimLight_FeatherOff", Float) = 0
	//�������C�g�ǉ��v���p�e�B.
	[Toggle(_)] _LightDirection_MaskOn ("LightDirection_MaskOn", Float) = 0
	_Tweak_LightDirection_MaskLevel ("Tweak_LightDirection_MaskLevel", Range(0, 0.5)) = 0
	[Toggle(_)] _Add_Antipodean_RimLight ("Add_Antipodean_RimLight", Float) = 0
	_Ap_RimLightColor ("Ap_RimLightColor", Color) = (1, 1, 1, 1)
	[Toggle(_)] _Is_LightColor_Ap_RimLight ("Is_LightColor_Ap_RimLight", Float) = 1
	_Ap_RimLight_Power ("Ap_RimLight_Power", Range(0, 1)) = 0.1
	[Toggle(_)] _Ap_RimLight_FeatherOff ("Ap_RimLight_FeatherOff", Float) = 0
//�������C�g�}�X�N.
_Set_RimLightMask ("Set_RimLightMask", 2D) = "white" { }
_Tweak_RimLightMaskLevel ("Tweak_RimLightMaskLevel", Range(-1, 1)) = 0
//�����܂�.
[Toggle(_)] _MatCap ("MatCap", Float) = 0
_MatCap_Sampler ("MatCap_Sampler", 2D) = "black" { }
//v.2.0.6
_BlurLevelMatcap ("Blur Level of MatCap_Sampler", Range(0, 10)) = 0
_MatCapColor ("MatCapColor", Color) = (1, 1, 1, 1)
[Toggle(_)] _Is_LightColor_MatCap ("Is_LightColor_MatCap", Float) = 1
[Toggle(_)] _Is_BlendAddToMatCap ("Is_BlendAddToMatCap", Float) = 1
_Tweak_MatCapUV ("Tweak_MatCapUV", Range(-0.5, 0.5)) = 0
_Rotate_MatCapUV ("Rotate_MatCapUV", Range(-1, 1)) = 0
//v.2.0.6
[Toggle(_)] _CameraRolling_Stabilizer ("Activate CameraRolling_Stabilizer", Float) = 0
[Toggle(_)] _Is_NormalMapForMatCap ("Is_NormalMapForMatCap", Float) = 0
_NormalMapForMatCap ("NormalMapForMatCap", 2D) = "bump" { }
_BumpScaleMatcap ("Scale for NormalMapforMatCap", Range(0, 1)) = 1
_Rotate_NormalMapForMatCapUV ("Rotate_NormalMapForMatCapUV", Range(-1, 1)) = 0
[Toggle(_)] _Is_UseTweakMatCapOnShadow ("Is_UseTweakMatCapOnShadow", Float) = 0
_TweakMatCapOnShadow ("TweakMatCapOnShadow", Range(0, 1)) = 0
//MatcapMask
_Set_MatcapMask ("Set_MatcapMask", 2D) = "white" { }
_Tweak_MatcapMaskLevel ("Tweak_MatcapMaskLevel", Range(-1, 1)) = 0
[Toggle(_)] _Inverse_MatcapMask ("Inverse_MatcapMask", Float) = 0
//v.2.0.5
[Toggle(_)] _Is_Ortho ("Orthographic Projection for MatCap", Float) = 0
////�V�g�̗֒ǉ��v���p�e�B.
[Toggle(_)] _AngelRing ("AngelRing", Float) = 0
_AngelRing_Sampler ("AngelRing_Sampler", 2D) = "black" { }
_AngelRing_Color ("AngelRing_Color", Color) = (1, 1, 1, 1)
[Toggle(_)] _Is_LightColor_AR ("Is_LightColor_AR", Float) = 1
_AR_OffsetU ("AR_OffsetU", Range(0, 0.5)) = 0
_AR_OffsetV ("AR_OffsetV", Range(0, 1)) = 0.3
[Toggle(_)] _ARSampler_AlphaOn ("ARSampler_AlphaOn", Float) = 0
//�����܂�.
//v.2.0.7 Emissive
[KeywordEnum(SIMPLE, ANIMATION)] _EMISSIVE ("EMISSIVE MODE", Float) = 0
_Emissive_Tex ("Emissive_Tex", 2D) = "white" { }
[HDR]_Emissive_Color ("Emissive_Color", Color) = (0, 0, 0, 1)
_Base_Speed ("Base_Speed", Float) = 0
_Scroll_EmissiveU ("Scroll_EmissiveU", Range(-1, 1)) = 0
_Scroll_EmissiveV ("Scroll_EmissiveV", Range(-1, 1)) = 0
_Rotate_EmissiveUV ("Rotate_EmissiveUV", Float) = 0
[Toggle(_)] _Is_PingPong_Base ("Is_PingPong_Base", Float) = 0
[Toggle(_)] _Is_ColorShift ("Activate ColorShift", Float) = 0
[HDR]_ColorShift ("ColorSift", Color) = (0, 0, 0, 1)
_ColorShift_Speed ("ColorShift_Speed", Float) = 0
[Toggle(_)] _Is_ViewShift ("Activate ViewShift", Float) = 0
[HDR]_ViewShift ("ViewSift", Color) = (0, 0, 0, 1)
[Toggle(_)] _Is_ViewCoord_Scroll ("Is_ViewCoord_Scroll", Float) = 0
//
//Outline
[KeywordEnum(NML, POS)] _OUTLINE ("OUTLINE MODE", Float) = 0
_Outline_Width ("Outline_Width", Float) = 0
_Outline_Width_Ramp ("Outline Width Ramp", 2D) = "white" { }
_Outline_Ramp_Max_Distance ("Outline Ramp Max Distance", Float) = 10
_Farthest_Distance ("Farthest_Distance", Float) = 100
_Nearest_Distance ("Nearest_Distance", Float) = 0.5
_Outline_Sampler ("Outline_Sampler", 2D) = "white" { }
_Outline_Color ("Outline_Color", Color) = (0.5, 0.5, 0.5, 1)
[Toggle(_)] _Is_BlendBaseColor ("Is_BlendBaseColor", Float) = 0
[Toggle(_)] _Is_LightColor_Outline ("Is_LightColor_Outline", Float) = 1
// ClippingMask paramaters from Here.
[HideInInspector]_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
// ClippingMask paramaters to here.
//v.2.0.4
[Toggle(_)] _Is_OutlineTex ("Is_OutlineTex", Float) = 0
_OutlineTex ("OutlineTex", 2D) = "white" { }
//Offset parameter
_Offset_Z ("Offset_Camera_Z", Float) = 0
//v.2.0.4.3 Baked Nrmal Texture for Outline
[Toggle(_)] _Is_BakedNormal ("Is_BakedNormal", Float) = 0
_BakedNormal ("Baked Normal for Outline", 2D) = "white" { }
//GI Intensity
_GI_Intensity ("GI_Intensity", Range(0, 1)) = 0
//For VR Chat under No effective light objects
_Unlit_Intensity ("Unlit_Intensity", Range(0.001, 4)) = 1
//v.2.0.5
[Toggle(_)] _Is_Filter_LightColor ("VRChat : SceneLights HiCut_Filter", Float) = 0
//Built-in Light Direction
[Toggle(_)] _Is_BLD ("Advanced : Activate Built-in Light Direction", Float) = 0
_Offset_X_Axis_BLD (" Offset X-Axis (Built-in Light Direction)", Range(-1, 1)) = -0.05
_Offset_Y_Axis_BLD (" Offset Y-Axis (Built-in Light Direction)", Range(-1, 1)) = 0.09
[Toggle(_)] _Inverse_Z_Axis_BLD (" Inverse Z-Axis (Built-in Light Direction)", Float) = 1

[Toggle(_)] _BaseColorVisible ("Channel mask", Float) = 1
[Toggle(_)] _BaseColorOverridden ("Channel mask", Float) = 0
_BaseColorMaskColor ("chennel mask color", Color) = (1, 1, 1, 0.8)

[Toggle(_)] _FirstShadeVisible ("Channel mask", Float) = 1
[Toggle(_)] _FirstShadeOverridden ("Channel mask", Float) = 0
_FirstShadeMaskColor ("chennel mask color", Color) = (0, 1, 1, 0.7)

[Toggle(_)] _SecondShadeVisible ("Channel mask", Float) = 1
[Toggle(_)] _SecondShadeOverridden ("Channel mask", Float) = 0
_SecondShadeMaskColor ("chennel mask color", Color) = (0, 0, 1, 0.6)

[Toggle(_)] _HighlightVisible ("Channel mask", Float) = 1
[Toggle(_)] _HighlightOverridden ("Channel mask", Float) = 0
_HighlightMaskColor ("Channel mask color", Color) = (1, 1, 0, 0.95)

[Toggle(_)] _AngelRingVisible ("Channel mask", Float) = 1
[Toggle(_)] _AngelRingOverridden ("Channel mask", Float) = 0
_AngelRingMaskColor ("Channel mask color", Color) = (0, 1, 0, 0.95)

[Toggle(_)] _RimLightVisible ("Channel mask", Float) = 1
[Toggle(_)] _RimLightOverridden ("Channel mask RimLightOverridden", Float) = 0
_RimLightMaskColor ("Channel mask color", Color) = (1, 0, 1, 0.9)

[Toggle(_)] _OutlineVisible ("Channel mask", Float) = 1
[Toggle(_)] _OutlineOverridden ("Channel mask", Float) = 0
_OutlineMaskColor ("Channel mask color", Color) = (0, 0, 0, 0.5)

[Toggle(_)] _ComposerMaskMode ("", Float) = 0
// to here parameters for UTS>


// ========= JTRP =========
[Header(JTRP)]
_LightIntensity ("_LightIntensity", Range(0, 3)) = 0.0
_AntiPerspectiveIntensity ("_AntiPerspectiveIntensity", Range(0, 1)) = 0.0
_ZOffset ("_ZOffset", Float) = -0.01

// Face / shadow
[Space]
_EnableRayTracingShadow ("Enable Ray Tracing Shadow", Float) = 1.0
[Toggle(_)]_IsHair ("Is Hair", Float) = 0
[Toggle(_)]_IsFace ("Is Face", Float) = 0
_HairShadowWidth ("Hair Shadow Width", Range(0, 100)) = 1
_HairShadowWidthRamp ("Hair Shadow Width Ramp", 2D) = "white" { }
_HairShadowRampMaxDistance ("Hair Shadow Ramp Max Distance", Float) = 10
_HairShadowBias ("Hair Shadow Bias", Range(0, 5)) = 0.0
_HairZOffset ("Hair Z Offset", Float) = 0.0
_FaceShadowBias ("Face Shadow Bias", Range(0, 5)) = 0.0

[Space]
_SphericalShadowNormalScale ("Spherical Shadow Normal Scale", Vector) = (1, 1, 1, 1)
_SphericalShadowIntensity ("Spherical Shadow Intensity", Range(0, 1)) = 0


[Header(Hair Tangent High Light)]
[Toggle(_)]_EnableTangentHighLight ("Enable Tangent HighLight", Float) = 0
_HairHighLightHighColor ("High Color(A: BlendDiffuse)", Color) = (1, 1, 1, 0)
_HairHighLightLowColor ("Low Color(A: BlendDiffuse)", Color) = (0.3, 0.3, 0.3, 0)
_HairHighLightIntensityInShadow ("Hair HighLight Intensity In Shadow", Range(0, 1)) = 0.5

[Space]
[PowerSlider(5)]_TangentHighLightWidth ("Tangent HighLight Width", Range(0, 1)) = 0.1
_TangentHighLightThreshold ("Tangent HighLight Threshold", Range(0, 1)) = 0.5
_TangentHighLightFeather ("Tangent HighLight Feather", Range(0, 1)) = 0.25
_TangentHighLightLowWidth ("Tangent HighLight Low Width", Range(0, 1)) = 0.1

[Space]
[NoScaleOffset]_HighLightMaskMap ("Mask(R Gradient G Mask B Offset A Width)", 2D) = "white" { }
[Toggle(_)]_HighLightMaskMapUV2 ("HighLight Mask Map UV2", Float) = 1
[NoScaleOffset]_HairHighLightGradientRamp ("Gradient Ramp(width 32)", 2D) = "gray" { }
_GradientRampIntensity ("Gradient Ramp Intensity", Range(0, 1)) = 0
[NoScaleOffset]_HairHighLightColorRamp ("Color Ramp", 2D) = "white" { }
[NoScaleOffset]_HairHighLightMaskRamp ("Mask Ramp", 2D) = "white" { }
[NoScaleOffset]_HairHighLightOffsetRamp ("Offset Ramp", 2D) = "gray" { }
[NoScaleOffset]_HairHighLightWidthRamp ("Width Ramp", 2D) = "white" { }
_HairHighLightRampST ("Scale(Color / Mask / Offset / Width)", Vector) = (1, 1, 1, 1)
_HairHighLightRampUVOffset ("Offset(Color / Mask / Offset / Width)", Vector) = (0, 0, 0, 0)
[Toggle(_)]_EnableHairHighLightRampUVCameraSpace ("Enable Ramp UV Camera Space", Float) = 0

[Space]
_HighLightMaskGradientScale ("HighLight Mask Gradient Map Scale", Range(-1, 1)) = 0
_HighLightMaskIntensity ("HighLight Mask Intensity", Range(0, 1)) = 0
[PowerSlider(5)]_HighLightMaskOffsetIntensity ("HighLight Mask Offset Intensity", Range(0, 1)) = 0
_HighLightMaskWidthIntensity ("HighLight Mask Width Intensity", Range(0, 20)) = 0

[Space]
[PowerSlider(5)]_HighLightRimOffset ("HighLight Rim Offset", Range(0, 1)) = 0
[PowerSlider(0.2)]_HighLightRimThreshold ("HighLight Rim Threshold", Range(0, 1)) = 0.93
[PowerSlider(5)]_HighLightRimWidth ("HighLight Rim Width", Range(0, 1)) = 0.06
_HighLightRimPower ("HighLight Rim Power", Range(0, 10)) = 2

[Space]
[NoScaleOffset]_TangentDirMap ("Tangent Dir Map(UV2 / Houdini)", 2D) = "gray" { }
_TangentDirMapIntensity ("Tangent Dir Map Intensity", Range(0, 1)) = 1
_TangentDirMapScale ("Tangent Dir Map Scale", Vector) = (1, 1, 1, 1)

[Space]
_SphericalTangentIntensity ("Spherical Tangent Intensity", Range(0, 1)) = 0
_SphericalTangentProjectionIntensity ("Spherical Tangent Projection Intensity", Range(0, 1)) = 0
_SphericalTangentScale ("Spherical Tangent Scale", Vector) = (1, 1, 1, 1)


[Header(Screen Space Rim Light)]
[Toggle(_)]_EnableSSRim ("Enable SS Rim", Float) = 0
_SSRimIntensity ("SS Rim Intensity", Range(0, 1)) = 1
[HDR]_SSRimColor ("SS Rim Color(A:Blend Diffuse)", Color) = (1, 1, 1, 0)
[PowerSlider(2)]_SSRimWidth ("SS Rim Width", Range(0, 100)) = 1
_SSRimWidthRamp ("SS Rim Width Ramp", 2D) = "white" { }
_SSRimRampMaxDistance ("SS Rim Ramp Max Distance", Float) = 10
_SSRimLength ("SS Rim Length", Range(-2, 2)) = 0
[Toggle(_)]_SSRimInvertLightDir ("SS Rim Invert LightDir", Float) = 0
_SSRimFeather ("SS Rim Feather", Range(0, 2)) = 1
_SSRimInShadow ("SS Rim In Shadow", Range(0, 1)) = 0.5
_SSRimMask ("Mask(R:Width A:Intensity)", 2D) = "white" { }


// unused
[Space(20)]
_EnableShadowColorRamp ("Enable Shadow Color Ramp", float) = 0
_ShadowColorRamp ("Shadow Color Ramp", 2D) = "white" { }
}

HLSLINCLUDE

#pragma target 4.5
#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

//-------------------------------------------------------------------------------------
// Variant
//-------------------------------------------------------------------------------------

#pragma shader_feature_local _ALPHATEST_ON
#pragma shader_feature_local _DEPTHOFFSET_ON
#pragma shader_feature_local _DOUBLESIDED_ON
#pragma shader_feature_local _ _VERTEX_DISPLACEMENT _PIXEL_DISPLACEMENT
#pragma shader_feature_local _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
#pragma shader_feature_local _DISPLACEMENT_LOCK_TILING_SCALE
#pragma shader_feature_local _PIXEL_DISPLACEMENT_LOCK_OBJECT_SCALE
#pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE

#pragma shader_feature_local _ _EMISSIVE_MAPPING_PLANAR _EMISSIVE_MAPPING_TRIPLANAR
#pragma shader_feature_local _ _MAPPING_PLANAR _MAPPING_TRIPLANAR
#pragma shader_feature_local _NORMALMAP_TANGENT_SPACE
#pragma shader_feature_local _ _REQUIRE_UV2 _REQUIRE_UV3

#pragma shader_feature_local _NORMALMAP
#pragma shader_feature_local _MASKMAP
#pragma shader_feature_local _BENTNORMALMAP
#pragma shader_feature_local _EMISSIVE_COLOR_MAP

// _ENABLESPECULAROCCLUSION keyword is obsolete but keep here for compatibility. Do not used
// _ENABLESPECULAROCCLUSION and _SPECULAR_OCCLUSION_X can't exist at the same time (the new _SPECULAR_OCCLUSION replace it)
// When _ENABLESPECULAROCCLUSION is found we define _SPECULAR_OCCLUSION_X so new code to work
#pragma shader_feature_local _ENABLESPECULAROCCLUSION
#pragma shader_feature_local _ _SPECULAR_OCCLUSION_NONE _SPECULAR_OCCLUSION_FROM_BENT_NORMAL_MAP
#ifdef _ENABLESPECULAROCCLUSION
#define _SPECULAR_OCCLUSION_FROM_BENT_NORMAL_MAP
#endif

#pragma shader_feature_local _HEIGHTMAP
#pragma shader_feature_local _TANGENTMAP
#pragma shader_feature_local _ANISOTROPYMAP
#pragma shader_feature_local _DETAIL_MAP
#pragma shader_feature_local _SUBSURFACE_MASK_MAP
#pragma shader_feature_local _THICKNESSMAP
#pragma shader_feature_local _IRIDESCENCE_THICKNESSMAP
#pragma shader_feature_local _SPECULARCOLORMAP
#pragma shader_feature_local _TRANSMITTANCECOLORMAP

#pragma shader_feature_local _DISABLE_DECALS
#pragma shader_feature_local _DISABLE_SSR
#pragma shader_feature_local _ENABLE_GEOMETRIC_SPECULAR_AA

// Keyword for transparent
#pragma shader_feature _SURFACE_TYPE_TRANSPARENT
#pragma shader_feature_local _ _BLENDMODE_ALPHA _BLENDMODE_ADD _BLENDMODE_PRE_MULTIPLY
#pragma shader_feature_local _BLENDMODE_PRESERVE_SPECULAR_LIGHTING
#pragma shader_feature_local _ENABLE_FOG_ON_TRANSPARENT
#pragma shader_feature_local _TRANSPARENT_WRITES_MOTION_VEC

// MaterialFeature are used as shader feature to allow compiler to optimize properly
#pragma shader_feature_local _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
#pragma shader_feature_local _MATERIAL_FEATURE_TRANSMISSION
#pragma shader_feature_local _MATERIAL_FEATURE_ANISOTROPY
#pragma shader_feature_local _MATERIAL_FEATURE_CLEAR_COAT
#pragma shader_feature_local _MATERIAL_FEATURE_IRIDESCENCE
#pragma shader_feature_local _MATERIAL_FEATURE_SPECULAR_COLOR

#pragma shader_feature_local _ADD_PRECOMPUTED_VELOCITY

// enable dithering LOD crossfade
#pragma multi_compile _ LOD_FADE_CROSSFADE

//enable GPU instancing support
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer

#pragma enable_d3d11_debug_symbols

//-------------------------------------------------------------------------------------
// Define
//-------------------------------------------------------------------------------------

#define JTRP_TOON_SHADER

// This shader support vertex modification
#define HAVE_VERTEX_MODIFICATION

// If we use subsurface scattering, enable output split lighting (for forward pass)
#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
#define OUTPUT_SPLIT_LIGHTING
#endif

#if defined(_TRANSPARENT_WRITES_MOTION_VEC) && defined(_SURFACE_TYPE_TRANSPARENT)
#define _WRITE_TRANSPARENT_MOTION_VECTOR
#endif
//-------------------------------------------------------------------------------------
// Include
//-------------------------------------------------------------------------------------

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"

//-------------------------------------------------------------------------------------
// variable declaration
//-------------------------------------------------------------------------------------

// #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.cs.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitProperties.hlsl"

#include "../../../Runtime/Shaders/Common/Common.hlsl"

// TODO:
// Currently, Lit.hlsl and LitData.hlsl are included for every pass. Split Lit.hlsl in two:
// LitData.hlsl and LitShading.hlsl (merge into the existing LitData.hlsl).
// LitData.hlsl should be responsible for preparing shading parameters.
// LitShading.hlsl implements the light loop API.
// LitData.hlsl is included here, LitShading.hlsl is included below for shading passes only.

ENDHLSL

SubShader
{
// This tags allow to use the shader replacement features
Tags { "RenderPipeline" = "HDRenderPipeline" "RenderType" = "HDLitShader" }

Pass
{
	Name "SceneSelectionPass"
	Tags { "LightMode" = "SceneSelectionPass" }

	Cull Off

	HLSLPROGRAM

	// Note: Require _ObjectId and _PassValue variables

	// We reuse depth prepass for the scene selection, allow to handle alpha correctly as well as tessellation and vertex animation
	#define SHADERPASS SHADERPASS_DEPTH_ONLY
	#define SCENESELECTIONPASS // This will drive the output of the scene selection shader
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitDepthPass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	#pragma editor_sync_compilation

	ENDHLSL

}

// Caution: The outline selection in the editor use the vertex shader/hull/domain shader of the first pass declare. So it should not bethe  meta pass.
Pass
{
	Name "GBuffer"
	Tags { "LightMode" = "GBuffer" }// This will be only for opaque object based on the RenderQueue index

	Cull [_CullMode]
	ZTest [_ZTestGBuffer]

	//            ZWrite on
	ZWrite off
	Stencil
	{
		WriteMask [_StencilWriteMaskGBuffer]
		Ref [_StencilRefGBuffer]
		Comp Always
		Pass Replace
	}

	HLSLPROGRAM

	#pragma multi_compile _ DEBUG_DISPLAY
	#pragma multi_compile _ LIGHTMAP_ON
	#pragma multi_compile _ DIRLIGHTMAP_COMBINED
	#pragma multi_compile _ DYNAMICLIGHTMAP_ON
	#pragma multi_compile _ SHADOWS_SHADOWMASK
	// Setup DECALS_OFF so the shader stripper can remove variants
	#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
	#pragma multi_compile _ LIGHT_LAYERS

	#ifndef DEBUG_DISPLAY
		// When we have alpha test, we will force a depth prepass so we always bypass the clip instruction in the GBuffer
		// Don't do it with debug display mode as it is possible there is no depth prepass in this case
		#define SHADERPASS_GBUFFER_BYPASS_ALPHA_TEST
	#endif

	#define SHADERPASS SHADERPASS_GBUFFER
	#ifdef DEBUG_DISPLAY
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
	#endif
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"

	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassGBuffer.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}


// Extracts information for lightmapping, GI (emission, albedo, ...)
// This pass it not used during regular rendering.
Pass
{
	Name "META"
	Tags { "LightMode" = "META" }

	Cull Off

	HLSLPROGRAM

	// Lightmap memo
	// DYNAMICLIGHTMAP_ON is used when we have an "enlighten lightmap" ie a lightmap updated at runtime by enlighten.This lightmap contain indirect lighting from realtime lights and realtime emissive material.Offline baked lighting(from baked material / light,
	// both direct and indirect lighting) will hand up in the "regular" lightmap->LIGHTMAP_ON.

	#define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassLightTransport.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}

Pass
{
	Name "ShadowCaster"
	Tags { "LightMode" = "ShadowCaster" }

	// Cull[_CullMode]
	Cull Front

	ZClip [_ZClip]
	ZWrite On
	ZTest LEqual

	ColorMask 0

	HLSLPROGRAM

	#define SHADERPASS SHADERPASS_SHADOWS
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitDepthPass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}

Pass
{
	Name "DepthOnly"
	Tags { "LightMode" = "DepthOnly" }

	Cull[_CullMode]

	// To be able to tag stencil with disableSSR information for forward
	Stencil
	{
		WriteMask [_StencilWriteMaskDepth]
		Ref [_StencilRefDepth]
		Comp Always
		Pass Replace
	}

	ZWrite On

	HLSLPROGRAM

	// In deferred, depth only pass don't output anything.
	// In forward it output the normal buffer
	#pragma multi_compile _ WRITE_NORMAL_BUFFER
	#pragma multi_compile _ WRITE_MSAA_DEPTH

	#define SHADERPASS SHADERPASS_DEPTH_ONLY
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"

	#ifdef WRITE_NORMAL_BUFFER // If enabled we need all regular interpolator
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
	#else
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitDepthPass.hlsl"
	#endif

	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}

Pass
{
	Name "MotionVectors"
	Tags { "LightMode" = "MotionVectors" }// Caution, this need to be call like this to setup the correct parameters by C++ (legacy Unity)

	// If velocity pass (motion vectors) is enabled we tag the stencil so it don't perform CameraMotionVelocity
	Stencil
	{
		WriteMask [_StencilWriteMaskMV]
		Ref [_StencilRefMV]
		Comp Always
		Pass Replace
	}

	Cull[_CullMode]

	ZWrite On

	HLSLPROGRAM

	#pragma multi_compile _ WRITE_NORMAL_BUFFER
	#pragma multi_compile _ WRITE_MSAA_DEPTH

	#define SHADERPASS SHADERPASS_MOTION_VECTORS
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#ifdef WRITE_NORMAL_BUFFER // If enabled we need all regular interpolator
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
	#else
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitMotionVectorPass.hlsl"
	#endif
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassMotionVectors.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}

Pass
{
	Name "DistortionVectors"
	Tags { "LightMode" = "DistortionVectors" }// This will be only for transparent object based on the RenderQueue index

	Stencil
	{
		WriteMask [_StencilRefDistortionVec]
		Ref [_StencilRefDistortionVec]
		Comp Always
		Pass Replace
	}

	Blend [_DistortionSrcBlend] [_DistortionDstBlend], [_DistortionBlurSrcBlend] [_DistortionBlurDstBlend]
	BlendOp Add, [_DistortionBlurBlendOp]
	ZTest [_ZTestModeDistortion]
	ZWrite off
	Cull [_CullMode]

	HLSLPROGRAM

	#define SHADERPASS SHADERPASS_DISTORTION
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitDistortionPass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDistortion.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}

Pass
{
	Name "TransparentDepthPrepass"
	Tags { "LightMode" = "TransparentDepthPrepass" }

	Cull[_CullMode]
	ZWrite On
	ColorMask 0

	HLSLPROGRAM

	#define SHADERPASS SHADERPASS_DEPTH_ONLY
	#define CUTOFF_TRANSPARENT_DEPTH_PREPASS
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitDepthPass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}

// Caution: Order is important: TransparentBackface, then Forward/ForwardOnly
Pass
{
	Name "TransparentBackface"
	Tags { "LightMode" = "TransparentBackface" }

	Blend [_SrcBlend] [_DstBlend], [_AlphaSrcBlend] [_AlphaDstBlend]
	ZWrite [_ZWrite]
	Cull Front
	ColorMask [_ColorMaskTransparentVel] 1
	ZTest [_ZTestTransparent]

	HLSLPROGRAM

	#pragma multi_compile _ DEBUG_DISPLAY
	#pragma multi_compile _ LIGHTMAP_ON
	#pragma multi_compile _ DIRLIGHTMAP_COMBINED
	#pragma multi_compile _ DYNAMICLIGHTMAP_ON
	#pragma multi_compile _ SHADOWS_SHADOWMASK
	// Setup DECALS_OFF so the shader stripper can remove variants
	#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT

	// Supported shadow modes per light type
	#pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH

	#define USE_CLUSTERED_LIGHTLIST // There is not FPTL lighting when using transparent

	#define SHADERPASS SHADERPASS_FORWARD
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

	#ifdef DEBUG_DISPLAY
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
	#endif

	// The light loop (or lighting architecture) is in charge to:
	// - Define light list
	// - Define the light loop
	// - Setup the constant/data
	// - Do the reflection hierarchy
	// - Provide sampling function for shadowmap, ies, cookie and reflection (depends on the specific use with the light loops like index array or atlas or single and texture format (cubemap/latlong))

	#define HAS_LIGHTLOOP

	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"

	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForward.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}

Pass
{
	Name "TransparentDepthPostpass"
	Tags { "LightMode" = "TransparentDepthPostpass" }

	Cull[_CullMode]
	ZWrite On
	ColorMask 0

	HLSLPROGRAM

	#define SHADERPASS SHADERPASS_DEPTH_ONLY
	#define CUTOFF_TRANSPARENT_DEPTH_POSTPASS
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitDepthPass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}


Pass
{
	// Added in UnityEngine.Rendering.HighDefinition.HDRenderPipeline.m_ForwardOnlyPassNames
	Name "JTRPLitToon"
	Tags { "LightMode" = "JTRPLitToon" }

	ZWrite[_ZWriteMode]
	ZTest LEqual
	Offset [_ZOffset], 0
	Cull[_CullMode]
	Blend SrcAlpha OneMinusSrcAlpha
	Stencil
	{

		Ref[_StencilNo]

		Comp[_StencilComp]
		Pass[_StencilOpPass]
		Fail[_StencilOpFail]
	}



	HLSLPROGRAM

	#pragma multi_compile _ DEBUG_DISPLAY
	#pragma multi_compile _ LIGHTMAP_ON
	#pragma multi_compile _ DIRLIGHTMAP_COMBINED
	#pragma multi_compile _ DYNAMICLIGHTMAP_ON
	#pragma multi_compile _ SHADOWS_SHADOWMASK
	// Setup DECALS_OFF so the shader stripper can remove variants
	#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT

	// Supported shadow modes per light type
	#pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH

	#pragma multi_compile USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST

	#define SHADERPASS SHADERPASS_FORWARD
	// In case of opaque we don't want to perform the alpha test, it is done in depth prepass and we use depth equal for ztest (setup from UI)
	// Don't do it with debug display mode as it is possible there is no depth prepass in this case
	#if !defined(_SURFACE_TYPE_TRANSPARENT) && !defined(DEBUG_DISPLAY)
		#define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST
	#endif

	#pragma shader_feature _ _SHADINGGRADEMAP
	// used in ShadingGradeMap
	#pragma shader_feature _IS_TRANSCLIPPING_OFF _IS_TRANSCLIPPING_ON
	#pragma shader_feature _IS_ANGELRING_OFF _IS_ANGELRING_ON
	// used in Shadow calculation
	#pragma shader_feature _ UTS_USE_RAYTRACING_SHADOW
	// used in DoubleShadeWithFeather
	#pragma shader_feature _IS_CLIPPING_OFF _IS_CLIPPING_MODE _IS_CLIPPING_TRANSMODE

	#pragma shader_feature _EMISSIVE_SIMPLE _EMISSIVE_ANIMATION
	#pragma shader_feature UTS_USE_RAYTRACING_SHADOW
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

	#ifdef DEBUG_DISPLAY
		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
	#endif

	// The light loop (or lighting architecture) is in charge to:
	// - Define light list
	// - Define the light loop
	// - Setup the constant/data
	// - Do the reflection hierarchy
	// - Provide sampling function for shadowmap, ies, cookie and reflection (depends on the specific use with the light loops like index array or atlas or single and texture format (cubemap/latlong))

	#define HAS_LIGHTLOOP

	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	//            #include "LightLoopCopy.hlsl"

	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	#include "UtsLightLoop.hlsl"
	#include "ShaderPassForwardUTS.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag

	ENDHLSL

}

// Pass
// {
	// 	Name "JTRPFace"
	// 	Tags { "LightMode" = "JTRPFace" }

	// 	ZWrite[_ZWriteMode]
	// 	ZTest LEqual
	// 	Offset [_ZOffset], 0
	// 	Cull[_CullMode]
	// 	Blend SrcAlpha OneMinusSrcAlpha
	// 	Stencil
	// 	{

		// 		Ref[_StencilNo]

		// 		Comp[_StencilComp]
		// 		Pass[_StencilOpPass]
		// 		Fail[_StencilOpFail]
	// 	}



	// 	HLSLPROGRAM

	// 	#pragma multi_compile _ DEBUG_DISPLAY
	// 	#pragma multi_compile _ LIGHTMAP_ON
	// 	#pragma multi_compile _ DIRLIGHTMAP_COMBINED
	// 	#pragma multi_compile _ DYNAMICLIGHTMAP_ON
	// 	#pragma multi_compile _ SHADOWS_SHADOWMASK
	// 	// Setup DECALS_OFF so the shader stripper can remove variants
	// 	#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT

	// 	// Supported shadow modes per light type
	// 	#pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH

	// 	#pragma multi_compile USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST

	// 	#define SHADERPASS SHADERPASS_FORWARD
	// 	// In case of opaque we don't want to perform the alpha test, it is done in depth prepass and we use depth equal for ztest (setup from UI)
	// 	// Don't do it with debug display mode as it is possible there is no depth prepass in this case
	// 	#if !defined(_SURFACE_TYPE_TRANSPARENT) && !defined(DEBUG_DISPLAY)
	// 		#define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST
	// 	#endif

	// 	#define JTRP_FACE_SHADER

	// 	#pragma shader_feature _ _SHADINGGRADEMAP
	// 	// used in ShadingGradeMap
	// 	#pragma shader_feature _IS_TRANSCLIPPING_OFF _IS_TRANSCLIPPING_ON
	// 	#pragma shader_feature _IS_ANGELRING_OFF _IS_ANGELRING_ON
	// 	// used in Shadow calculation
	// 	#pragma shader_feature _ UTS_USE_RAYTRACING_SHADOW
	// 	// used in DoubleShadeWithFeather
	// 	#pragma shader_feature _IS_CLIPPING_OFF _IS_CLIPPING_MODE _IS_CLIPPING_TRANSMODE

	// 	#pragma shader_feature _EMISSIVE_SIMPLE _EMISSIVE_ANIMATION
	// 	#pragma shader_feature UTS_USE_RAYTRACING_SHADOW
	// 	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
	// 	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

	// 	#ifdef DEBUG_DISPLAY
	// 		#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
	// 	#endif

	// 	#define HAS_LIGHTLOOP

	// 	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
	// 	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
	// 	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
	// 	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
	// 	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
	// 	#include "UtsLightLoop.hlsl"
	// 	#include "ShaderPassForwardUTS.hlsl"

	// 	#pragma vertex Vert
	// 	#pragma fragment Frag

	// 	ENDHLSL

// }

Pass
{
	Name "Outline"
	Tags { "LightMode" = "SRPDefaultUnlit" }
	Cull Front
	// Cull[_SRPDefaultUnlitColMode]
	// ColorMask[_SPRDefaultUnlitColorMask]
	Blend SrcAlpha OneMinusSrcAlpha
	Stencil
	{
		Ref[_StencilNo]
		Comp[_StencilComp]
		Pass[_StencilOpPass]
		Fail[_StencilOpFail]
	}

	HLSLPROGRAM

	#pragma multi_compile _IS_OUTLINE_CLIPPING_NO _IS_OUTLINE_CLIPPING_YES
	#pragma multi_compile _OUTLINE_NML _OUTLINE_POS
	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
	#include "HDRPToonHead.hlsl"
	#include "HDRPToonOutline.hlsl"

	#pragma vertex vert
	#pragma fragment frag
	ENDHLSL

}

Pass
{
	Name "JTRPMask"
	Tags { "LightMode" = "JTRPMask" }
	Cull Off
	BlendOp Max
	
	HLSLPROGRAM

	#include "ShaderPassJTRPMask.hlsl"
	
	#pragma vertex vert
	#pragma fragment frag
	ENDHLSL

}
}



CustomEditor "UnityEditor.Rendering.HDRP.Toon.HDRPToonGUI"
}
