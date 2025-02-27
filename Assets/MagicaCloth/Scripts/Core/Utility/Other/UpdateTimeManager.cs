﻿// Magica Cloth.
// Copyright (c) MagicaSoft, 2020-2021.
// https://magicasoft.jp
using UnityEngine;

namespace MagicaCloth
{
    /// <summary>
    /// 時間管理クラス
    /// </summary>
    [System.Serializable]
    public class UpdateTimeManager
    {
        // アップデート回数
        public enum UpdateCount
        {
            _60 = 60,
            _90_Default = 90,
            _120 = 120,
            _150 = 150,
            _180 = 180,
        }

        // １秒間の更新回数
        [SerializeField]
        private UpdateCount updatePerSeccond = UpdateCount._90_Default;

        // 更新モード
        public enum UpdateMode
        {
            UnscaledTime = 0,   // 非同期更新
            OncePerFrame = 1,   // 固定更新（基本１フレームに１回）

            DelayUnscaledTime = 10, // 非同期更新（遅延実行）
        }
        [SerializeField]
        private UpdateMode updateMode = UpdateMode.UnscaledTime;

        // グローバルタイムスケール
        private float timeScale = 1.0f;

        /// <summary>
        /// 遅延実行時の未来予測率
        /// </summary>
        [SerializeField]
        [Range(0.0f, 1.0f)]
        private float futurePredictionRate = 1.0f;

        /// <summary>
        /// ボーンスケールの更新(Unity2019.2.13まで)
        /// </summary>
        [SerializeField]
        private bool updateBoneScale = false;


        private int fixedUpdateCount = 0;

        //=========================================================================================
        public void ResetFixedUpdateCount()
        {
            fixedUpdateCount = 0;
        }

        public void AddFixedUpdateCount()
        {
            fixedUpdateCount++;
        }

        public int FixedUpdateCount
        {
            get
            {
                return fixedUpdateCount;
            }
        }

        /// <summary>
        /// アップデートモード取得
        /// </summary>
        /// <returns></returns>
        public UpdateMode GetUpdateMode()
        {
            return updateMode;
        }

        public void SetUpdateMode(UpdateMode mode)
        {
            updateMode = mode;
        }

        /// <summary>
        /// １秒間の更新回数
        /// </summary>
        public int UpdatePerSecond
        {
            get
            {
                return (int)updatePerSeccond;
            }
        }

        public void SetUpdatePerSecond(UpdateCount ucount)
        {
            updatePerSeccond = ucount;
        }

        /// <summary>
        /// 更新間隔時間
        /// </summary>
        public float UpdateIntervalTime
        {
            get
            {
                return 1.0f / UpdatePerSecond;
            }
        }

        /// <summary>
        /// 更新力（90upsを基準とした倍数）
        /// 60fps = 1.5 / 90ups = 1.0f / 120fps = 0.75
        /// </summary>
        public float UpdatePower
        {
            get
            {
                float power = 90.0f / (float)UpdatePerSecond;
                //power = Mathf.Pow(power, 0.3f); // 調整
                return power;
            }
        }

        /// <summary>
        /// タイムスケール
        /// 1.0未満に設定することで全体のスロー再生が可能
        /// ただし完全なスローではないので注意
        /// </summary>
        public float TimeScale
        {
            get
            {
                return timeScale;
            }
            set
            {
                timeScale = Mathf.Clamp01(value);
            }
        }

        /// <summary>
        /// 現在のフレーム更新時間
        /// </summary>
        public float DeltaTime
        {
            get
            {
                return Time.deltaTime;
            }
        }

        public float PhysicsDeltaTime
        {
            get
            {
                return Time.fixedDeltaTime * fixedUpdateCount;
            }
        }

        /// <summary>
        /// 現在の平均フレーム更新時間(=平均FPS)
        /// </summary>
        public float AverageDeltaTime
        {
            get
            {
                return Time.smoothDeltaTime;
            }
        }

        /// <summary>
        /// 非同期時間更新判定
        /// </summary>
        public bool IsUnscaledUpdate
        {
            get
            {
                return updateMode == UpdateMode.UnscaledTime || updateMode == UpdateMode.DelayUnscaledTime;
            }
        }

        /// <summary>
        /// 遅延実行判定
        /// </summary>
        public bool IsDelay
        {
            get
            {
                return updateMode == UpdateMode.DelayUnscaledTime;
            }
        }

        /// <summary>
        /// 遅延実行時の未来予測率(0.0-1.0)
        /// </summary>
        public float FuturePredictionRate
        {
            get
            {
                return futurePredictionRate;
            }
            set
            {
                futurePredictionRate = Mathf.Clamp01(value);
            }
        }

        /// <summary>
        /// ボーンスケール更新判定(Unity2019.2.13まで)
        /// </summary>
        public bool UpdateBoneScale
        {
            get
            {
                return updateBoneScale;
            }
            set
            {
                updateBoneScale = value;
            }
        }

        /// <summary>
        /// この端末が使用可能なワーカースレッド数
        /// </summary>
        /// <returns></returns>
        public int WorkerMaximumCount
        {
            get
            {
#if UNITY_2019_4_OR_NEWER
                return Unity.Jobs.LowLevel.Unsafe.JobsUtility.JobWorkerMaximumCount;
#else
                // Unity2019.4未満では取得できないので定数を返す
                return 4;
#endif
            }
        }
    }
}
