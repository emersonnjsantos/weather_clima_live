package domain

type WeatherData struct {
	Lat            float64         `json:"lat"`
	Lon            float64         `json:"lon"`
	Timezone       string          `json:"timezone"`
	TimezoneOffset int             `json:"timezone_offset"`
	Current        CurrentWeather  `json:"current"`
	Hourly         []HourlyForecast `json:"hourly"`
	Daily          []DailyForecast  `json:"daily"`
}

type CurrentWeather struct {
	Dt         int64     `json:"dt"`
	Sunrise    int64     `json:"sunrise"`
	Sunset     int64     `json:"sunset"`
	Temp       float64   `json:"temp"`
	FeelsLike  float64   `json:"feels_like"`
	Pressure   int       `json:"pressure"`
	Humidity   int       `json:"humidity"`
	DewPoint   float64   `json:"dew_point"`
	UVI        float64   `json:"uvi"`
	Clouds     int       `json:"clouds"`
	Visibility int       `json:"visibility"`
	WindSpeed  float64   `json:"wind_speed"`
	WindDeg    int       `json:"wind_deg"`
	Weather    []Weather `json:"weather"`
}

type HourlyForecast struct {
	Dt         int64     `json:"dt"`
	Temp       float64   `json:"temp"`
	FeelsLike  float64   `json:"feels_like"`
	Pressure   int       `json:"pressure"`
	Humidity   int       `json:"humidity"`
	DewPoint   float64   `json:"dew_point"`
	UVI        float64   `json:"uvi"`
	Clouds     int       `json:"clouds"`
	Visibility int       `json:"visibility"`
	WindSpeed  float64   `json:"wind_speed"`
	WindDeg    int       `json:"wind_deg"`
	WindGust   float64   `json:"wind_gust"`
	Weather    []Weather `json:"weather"`
	Pop        float64   `json:"pop"`
}

type DailyForecast struct {
	Dt       int64     `json:"dt"`
	Sunrise  int64     `json:"sunrise"`
	Sunset   int64     `json:"sunset"`
	Moonrise int64     `json:"moonrise"`
	Moonset  int64     `json:"moonset"`
	MoonPhase float64  `json:"moon_phase"`
	Summary  string    `json:"summary"`
	Temp     Temp      `json:"temp"`
	FeelsLike FeelsLike `json:"feels_like"`
	Pressure int       `json:"pressure"`
	Humidity int       `json:"humidity"`
	DewPoint float64   `json:"dew_point"`
	WindSpeed float64  `json:"wind_speed"`
	WindDeg  int       `json:"wind_deg"`
	WindGust float64   `json:"wind_gust"`
	Weather  []Weather `json:"weather"`
	Clouds   int       `json:"clouds"`
	Pop      float64   `json:"pop"`
	UVI      float64   `json:"uvi"`
}

type Weather struct {
	ID          int    `json:"id"`
	Main        string `json:"main"`
	Description string `json:"description"`
	Icon        string `json:"icon"`
}

type Temp struct {
	Day   float64 `json:"day"`
	Min   float64 `json:"min"`
	Max   float64 `json:"max"`
	Night float64 `json:"night"`
	Eve   float64 `json:"eve"`
	Morn  float64 `json:"morn"`
}

type FeelsLike struct {
	Day   float64 `json:"day"`
	Night float64 `json:"night"`
	Eve   float64 `json:"eve"`
	Morn  float64 `json:"morn"`
}
