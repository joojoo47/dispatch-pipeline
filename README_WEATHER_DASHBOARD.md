# Weather Dashboard Web Application

A modern, responsive weather dashboard that displays real-time weather data for any location using the OpenWeatherMap API.

## Features

- **Location Search**: Search for weather data by city name
- **Current Location**: Get weather data for your current location using geolocation
- **Comprehensive Weather Data**:
  - Current temperature and "feels like" temperature
  - Weather description with icons
  - Humidity percentage
  - Wind speed
  - Atmospheric pressure
  - Visibility
  - Sunrise and sunset times
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Modern UI**: Clean and intuitive user interface with smooth animations
- **Error Handling**: Clear error messages for better user experience

## Screenshots

The dashboard features:
- A gradient header with search functionality
- Large temperature display with weather icons
- Grid layout showing detailed weather metrics
- Fully responsive design that adapts to all screen sizes

## Getting Started

### Prerequisites

- A modern web browser (Chrome, Firefox, Safari, Edge)
- An OpenWeatherMap API key (free)
- A local web server or simple HTTP server to run the application

### Obtaining an OpenWeatherMap API Key

Follow these steps to get your free API key:

1. **Sign Up for OpenWeatherMap**:
   - Go to [OpenWeatherMap](https://openweathermap.org/)
   - Click on "Sign In" or "Sign Up" in the top right corner
   - Create a free account by providing:
     - Username
     - Email address
     - Password
   - Verify your email address

2. **Generate Your API Key**:
   - After logging in, go to your profile by clicking your username
   - Navigate to "My API keys" or go directly to: https://home.openweathermap.org/api_keys
   - You'll see a default API key already created, or you can create a new one
   - Click "Generate" to create a new API key (optional)
   - Copy your API key (it looks like: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`)

3. **API Key Activation**:
   - **Important**: New API keys may take up to 2 hours to activate
   - You'll receive an email confirmation when your key is active
   - Free tier includes:
     - 60 calls per minute
     - 1,000,000 calls per month
     - Current weather data access

### Installation and Setup

1. **Download the Files**:
   ```bash
   # Clone the repository or download these files:
   # - index.html
   # - styles.css
   # - app.js
   # - README_WEATHER_DASHBOARD.md
   ```

2. **Configure Your API Key**:
   - Open `app.js` in a text editor
   - Find this line near the top of the file:
     ```javascript
     const API_KEY = 'YOUR_API_KEY_HERE';
     ```
   - Replace `'YOUR_API_KEY_HERE'` with your actual API key:
     ```javascript
     const API_KEY = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';
     ```
   - Save the file

3. **Run the Application**:

   **Option A: Using Python (Recommended)**
   ```bash
   # Navigate to the project directory
   cd /path/to/weather-dashboard

   # Python 3
   python3 -m http.server 8000

   # Python 2
   python -m SimpleHTTPServer 8000
   ```
   Then open your browser and go to: `http://localhost:8000`

   **Option B: Using Node.js**
   ```bash
   # Install http-server globally (one time only)
   npm install -g http-server

   # Run the server
   http-server -p 8000
   ```
   Then open your browser and go to: `http://localhost:8000`

   **Option C: Using VS Code Live Server**
   - Install the "Live Server" extension in VS Code
   - Right-click on `index.html`
   - Select "Open with Live Server"

   **Option D: Direct File Opening (Not Recommended)**
   - You can open `index.html` directly in your browser
   - Note: Some features like geolocation may not work with the `file://` protocol
   - A local server is recommended for full functionality

## How to Use

### Search by City Name
1. Enter a city name in the search input (e.g., "London", "New York", "Tokyo")
2. Click the "Search" button or press Enter
3. View the weather data displayed on the dashboard

### Use Current Location
1. Click the "Current Location" button
2. Allow location access when prompted by your browser
3. View weather data for your current location

### Understanding the Weather Data

- **Temperature**: Displayed in Celsius (°C)
- **Feels Like**: The perceived temperature considering wind and humidity
- **Humidity**: Percentage of moisture in the air (0-100%)
- **Wind Speed**: Measured in meters per second (m/s)
- **Pressure**: Atmospheric pressure in hectopascals (hPa)
- **Visibility**: How far you can see, measured in kilometers (km)
- **Sunrise/Sunset**: Local times based on the location's timezone

## Project Structure

```
weather-dashboard/
│
├── index.html              # Main HTML structure
├── styles.css              # Styling and responsive design
├── app.js                  # JavaScript logic and API integration
└── README_WEATHER_DASHBOARD.md  # This file
```

## Technologies Used

- **HTML5**: Semantic markup and structure
- **CSS3**: Modern styling with flexbox and grid layouts
- **JavaScript (ES6+)**: Async/await for API calls, modern DOM manipulation
- **OpenWeatherMap API**: Weather data provider
- **Geolocation API**: Browser's built-in location services

## Browser Compatibility

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Opera (latest)

Note: Internet Explorer is not supported due to the use of modern JavaScript features.

## API Rate Limits

The free tier of OpenWeatherMap API includes:
- **60 calls per minute**
- **1,000,000 calls per month**

This is more than sufficient for personal use. If you need more, consider upgrading to a paid plan.

## Troubleshooting

### "Please configure your OpenWeatherMap API key" error
- Make sure you've replaced `YOUR_API_KEY_HERE` in `app.js` with your actual API key
- Ensure there are no extra spaces or quotes around the API key

### "Invalid API key" error
- Verify your API key is correct
- Wait up to 2 hours for new API keys to activate
- Check if your API key is active at https://home.openweathermap.org/api_keys

### "City not found" error
- Check the spelling of the city name
- Try adding the country code (e.g., "London, UK" or "Paris, FR")
- Try a larger city in the same region

### Geolocation not working
- Ensure you're running the app on a local server (not opening the file directly)
- Check that you've allowed location access in your browser
- Some browsers require HTTPS for geolocation (local development servers are usually exempt)

### Weather data not displaying
- Open the browser console (F12) to check for errors
- Verify your internet connection
- Check if you've exceeded the API rate limit

## Security Notes

- **Never commit your API key to public repositories**
- For production applications, API keys should be stored on a backend server
- This application is designed for learning and personal use
- Consider implementing a backend proxy for production deployments

## Customization

### Change Temperature Units
To display temperature in Fahrenheit instead of Celsius:
1. Open `app.js`
2. Change `units=metric` to `units=imperial` in the API URLs
3. Update the temperature unit display in `index.html` from `°C` to `°F`

### Modify Color Scheme
Edit the CSS variables in `styles.css`:
```css
:root {
    --primary-color: #4a90e2;    /* Change to your preferred color */
    --secondary-color: #357abd;
    /* ... other variables ... */
}
```

### Add More Weather Data
OpenWeatherMap API provides additional data. Consult their [API documentation](https://openweathermap.org/current) to add more features.

## Future Enhancements

Potential improvements to consider:
- 5-day weather forecast
- Hourly weather predictions
- Weather alerts and warnings
- Favorite locations
- Temperature unit toggle (Celsius/Fahrenheit)
- Multiple language support
- Dark mode toggle
- Weather charts and graphs
- Local storage for recent searches

## Resources

- [OpenWeatherMap API Documentation](https://openweathermap.org/api)
- [OpenWeatherMap Weather Conditions](https://openweathermap.org/weather-conditions)
- [MDN Web Docs - Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
- [MDN Web Docs - Geolocation API](https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API)

## License

This project is open source and available for personal and educational use.

## Support

If you encounter any issues:
1. Check the Troubleshooting section above
2. Verify your API key is configured correctly
3. Check the browser console for error messages
4. Ensure you have a stable internet connection

## Acknowledgments

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- Icons from OpenWeatherMap icon set
- Built with modern web technologies

---

**Happy weather checking! 🌤️**
