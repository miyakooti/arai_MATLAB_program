 MELCTRL_DEVTYPE_EEG		= hex2dec('1000');		% EEG電極
MELCTRL_DEVTYPE_EXT		= hex2dec('2000');		% EXT入力

MELCTRL_INFO_VERSION	= hex2dec('00');		% 本体バージョン
MELCTRL_INFO_UNITSIZE	= hex2dec('01');		% １ユニットのサイズ
MELCTRL_INFO_FREQ		= hex2dec('02');		% サンプリング周波数
MELCTRL_INFO_BATTERY	= hex2dec('03');		% 本体のバッテリー状態
MELCTRL_INFO_CH_N		= hex2dec('04');		% 転送チャネル数
MELCTRL_INFO_STATE		= hex2dec('05');		% 動作状態（計測中／待機中）
MELCTRL_INFO_COMPORT	= hex2dec('06');		% 接続COMポート

MELCTRL_CH_TYPE			= hex2dec('01');		% 電極のデバイス種別
MELCTRL_CH_DEVNUM		= hex2dec('02');		% 電極番号
MELCTRL_CH_ISACTIVE		= hex2dec('03');		% 電極の使用／未使用指定
MELCTRL_CH_GAIN			= hex2dec('04');		% 電極のゲイン倍率

