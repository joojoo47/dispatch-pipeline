// Weather Dashboard Application
// This application fetches weather data from OpenWeatherMap API

// Configuration - Users need to replace this with their own API key
const API_KEY = 'YOUR_API_KEY_HERE'; // Replace with your OpenWeatherMap API key
const API_BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';

// DOM Elements
const cityInput = document.getElementById('cityInput');
const searchBtn = document.getElementById('searchBtn');
const currentLocationBtn = document.getElementById('currentLocationBtn');
const errorMessage = document.getElementById('errorMessage');
const loadingIndicator = document.getElementById('loadingIndicator');
const weatherDisplay = document.getElementById('weatherDisplay');
const welcomeMessage = document.getElementById('welcomeMessage');

// Weather display elements
const cityName = document.getElementById('cityName');
const dateTime = document.getElementById('dateTime');
const weatherIcon = document.getElementById('weatherIcon');
const temperature = document.getElementById('temperature');
const weatherDescription = document.getElementById('weatherDescription');
const feelsLike = document.getElementById('feelsLike');
const humidity = document.getElementById('humidity');
const windSpeed = document.getElementById('windSpeed');
const pressure = document.getElementById('pressure');
const visibility = document.getElementById('visibility');
const sunrise = document.getElementById('sunrise');
const sunset = document.getElementById('sunset');

// Event Listeners
searchBtn.addEventListener('click', handleSearch);
currentLocationBtn.addEventListener('click', handleCurrentLocation);
cityInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        handleSearch();
    }
});

// Initialize the app
function init() {
    // Check if API key is configured
    if (API_KEY === 'YOUR_API_KEY_HERE') {
        showError('Please configure your OpenWeatherMap API key in app.js. See README_WEATHER_DASHBOARD.md for instructions.');
    }
    
    // Update current date and time
    updateDateTime();
    setInterval(updateDateTime, 60000); // Update every minute
}

// Handle search button click
function handleSearch() {
    const city = cityInput.value.trim();
    
    if (!city) {
        showError('Please enter a city name');
        return;
    }
    
    if (API_KEY === 'YOUR_API_KEY_HERE') {
        showError('Please configure your OpenWeatherMap API key first. See README_WEATHER_DASHBOARD.md for instructions.');
        return;
    }
    
    fetchWeatherByCity(city);
}

// Handle current location button click
function handleCurrentLocation() {
    if (API_KEY === 'YOUR_API_KEY_HERE') {
        showError('Please configure your OpenWeatherMap API key first. See README_WEATHER_DASHBOARD.md for instructions.');
        return;
    }
    
    if (!navigator.geolocation) {
        showError('Geolocation is not supported by your browser');
        return;
    }
    
    showLoading();
    
    navigator.geolocation.getCurrentPosition(
        (position) => {
            const { latitude, longitude } = position.coords;
            fetchWeatherByCoordinates(latitude, longitude);
        },
        (error) => {
            hideLoading();
            switch(error.code) {
                case error.PERMISSION_DENIED:
                    showError('Location access denied. Please allow location access and try again.');
                    break;
                case error.POSITION_UNAVAILABLE:
                    showError('Location information is unavailable.');
                    break;
                case error.TIMEOUT:
                    showError('Location request timed out.');
                    break;
                default:
                    showError('An unknown error occurred while getting your location.');
            }
        }
    );
}

// Fetch weather data by city name
async function fetchWeatherByCity(city) {
    showLoading();
    
    try {
        const url = `${API_BASE_URL}?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=metric`;
        const response = await fetch(url);
        
        if (!response.ok) {
            if (response.status === 404) {
                throw new Error('City not found. Please check the spelling and try again.');
            } else if (response.status === 401) {
                throw new Error('Invalid API key. Please check your OpenWeatherMap API key.');
            } else {
                throw new Error('Failed to fetch weather data. Please try again later.');
            }
        }
        
        const data = await response.json();
        displayWeather(data);
    } catch (error) {
        hideLoading();
        showError(error.message);
    }
}

// Fetch weather data by coordinates
async function fetchWeatherByCoordinates(lat, lon) {
    try {
        const url = `${API_BASE_URL}?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`;
        const response = await fetch(url);
        
        if (!response.ok) {
            if (response.status === 401) {
                throw new Error('Invalid API key. Please check your OpenWeatherMap API key.');
            } else {
                throw new Error('Failed to fetch weather data. Please try again later.');
            }
        }
        
        const data = await response.json();
        displayWeather(data);
    } catch (error) {
        hideLoading();
        showError(error.message);
    }
}

// Display weather data
function displayWeather(data) {
    hideLoading();
    hideError();
    
    // Update city name and country
    cityName.textContent = `${data.name}, ${data.sys.country}`;
    
    // Update temperature
    temperature.textContent = Math.round(data.main.temp);
    feelsLike.textContent = Math.round(data.main.feels_like);
    
    // Update weather description and icon
    weatherDescription.textContent = data.weather[0].description;
    const iconCode = data.weather[0].icon;
    weatherIcon.src = `https://openweathermap.org/img/wn/${iconCode}@2x.png`;
    weatherIcon.alt = data.weather[0].description;
    
    // Update weather details
    humidity.textContent = `${data.main.humidity}%`;
    windSpeed.textContent = `${data.wind.speed} m/s`;
    pressure.textContent = `${data.main.pressure} hPa`;
    visibility.textContent = `${(data.visibility / 1000).toFixed(1)} km`;
    
    // Update sunrise and sunset times
    sunrise.textContent = formatTime(data.sys.sunrise, data.timezone);
    sunset.textContent = formatTime(data.sys.sunset, data.timezone);
    
    // Show weather display, hide welcome message
    welcomeMessage.classList.add('hide');
    weatherDisplay.classList.add('show');
    
    // Clear input
    cityInput.value = '';
}

// Format Unix timestamp to local time
function formatTime(timestamp, timezoneOffset) {
    const date = new Date((timestamp + timezoneOffset) * 1000);
    const hours = date.getUTCHours().toString().padStart(2, '0');
    const minutes = date.getUTCMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
}

// Update current date and time
function updateDateTime() {
    const now = new Date();
    const options = { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    };
    dateTime.textContent = now.toLocaleDateString('en-US', options);
}

// Show loading indicator
function showLoading() {
    loadingIndicator.classList.add('show');
    weatherDisplay.classList.remove('show');
    welcomeMessage.classList.add('hide');
    searchBtn.disabled = true;
    currentLocationBtn.disabled = true;
}

// Hide loading indicator
function hideLoading() {
    loadingIndicator.classList.remove('show');
    searchBtn.disabled = false;
    currentLocationBtn.disabled = false;
}

// Show error message
function showError(message) {
    errorMessage.textContent = message;
    errorMessage.classList.add('show');
    
    // Auto-hide error after 5 seconds
    setTimeout(() => {
        hideError();
    }, 5000);
}

// Hide error message
function hideError() {
    errorMessage.classList.remove('show');
}

// Initialize the app when DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
