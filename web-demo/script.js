// Stride Web Demo - JavaScript Implementation
// Modern walking route generator with interactive features

class StrideApp {
    constructor() {
        this.currentTab = 'walk';
        this.userLocation = null;
        this.isGettingLocation = false;
        this.locationWatchId = null;
        this.currentRoute = null;
        this.publicWalks = this.generateMockPublicWalks();
        this.userLocations = [];
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupTabs();
        this.requestLocation();
    }    setupEventListeners() {
        // Duration slider
        const durationSlider = document.getElementById('durationSlider');
        const durationDisplay = document.getElementById('durationDisplay');
        
        if (durationSlider && durationDisplay) {
            durationSlider.addEventListener('input', (e) => {
                durationDisplay.textContent = `${e.target.value} min`;
            });
        }

        // Duration suggestion buttons
        document.querySelectorAll('.suggestion-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const duration = e.target.dataset.duration;
                if (durationSlider && durationDisplay) {
                    durationSlider.value = duration;
                    durationDisplay.textContent = `${duration} min`;
                }
            });
        });

        // Generate walk button
        const generateBtn = document.getElementById('generateWalkBtn');
        if (generateBtn) {
            generateBtn.addEventListener('click', () => {
                this.generateRandomWalk();
            });
        }        // Multi-location handlers
        const addCurrentLocationBtn = document.getElementById('addCurrentLocation');
        const locationSearch = document.getElementById('locationSearch');
        const generateMultiBtn = document.getElementById('generateMultiBtn');
        
        if (addCurrentLocationBtn) {
            addCurrentLocationBtn.addEventListener('click', () => {
                this.addCurrentLocation();
            });
        }
        
        if (locationSearch) {
            locationSearch.addEventListener('input', (e) => {
                this.handleLocationSearch(e.target.value);
            });
        }
          if (generateMultiBtn) {
            generateMultiBtn.addEventListener('click', () => {
                this.generateMultiLocationWalk();
            });
        }

        // Modal overlay click handler
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal-overlay')) {
                this.closeMapModal();
            }
        });

        // Escape key to close modal
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.closeMapModal();
            }
        });
    }

    showView(viewName) {
        this.currentView = viewName;
        
        // Hide all views
        document.querySelectorAll('.view').forEach(view => {
            view.classList.remove('active');
        });
        
        // Show selected view
        document.getElementById(`${viewName}-view`).classList.add('active');
        
        // Update specific view content
        if (viewName === 'explore') {
            this.loadPublicWalks();
        }
    }

    updateTabSelection() {
        document.querySelectorAll('.tab-button').forEach(button => {
            button.classList.remove('active');
            if (button.dataset.view === this.currentView) {
                button.classList.add('active');
            }
        });
    }    generateRandomWalk() {
        const generateBtn = document.getElementById('generateWalkBtn');
        const generateText = document.getElementById('generateText');
        const generateIcon = document.getElementById('generateIcon');
        const generateSpinner = document.getElementById('generateSpinner');
        const walkResult = document.getElementById('walkResult');
        
        // Get duration
        const durationSlider = document.getElementById('durationSlider');
        const duration = durationSlider ? parseInt(durationSlider.value) : 30;
        
        // Show loading state
        if (generateBtn) generateBtn.disabled = true;
        if (generateText) generateText.textContent = 'Generating...';
        if (generateIcon) generateIcon.style.display = 'none';
        if (generateSpinner) generateSpinner.style.display = 'inline-block';
        
        // Simulate API call
        setTimeout(() => {
            // Generate mock route
            const route = this.generateMockRoute(duration);
            this.currentRoute = route;
            
            // Update UI with results
            this.displayWalkResult(route);
            
            // Reset button state
            if (generateBtn) generateBtn.disabled = false;
            if (generateText) generateText.textContent = 'Generate New Route';
            if (generateIcon) generateIcon.style.display = 'inline-block';
            if (generateSpinner) generateSpinner.style.display = 'none';
            
        }, 2000);
    }    generateMultiLocationWalk() {
        if (this.userLocations.length < 2) {
            this.showToast('Please add at least 2 locations', 'error');
            return;
        }

        const generateBtn = document.getElementById('generateMultiBtn');
        const generateIcon = document.getElementById('generateMultiIcon');
        const generateSpinner = document.getElementById('generateMultiSpinner');
        const generateText = document.getElementById('generateMultiText');
        const multiResult = document.getElementById('multiResult');
        
        // Show loading state
        if (generateBtn) generateBtn.disabled = true;
        if (generateText) generateText.textContent = 'Generating...';
        if (generateIcon) generateIcon.style.display = 'none';
        if (generateSpinner) generateSpinner.style.display = 'inline-block';

        setTimeout(() => {
            const route = this.generateMultiMockRoute(this.userLocations);
            this.currentRoute = route;
            
            // Update multi-location result display
            this.displayMultiLocationResult(route);
            
            this.showToast('Multi-location route created!', 'success');
            
            // Reset button state
            if (generateBtn) generateBtn.disabled = false;
            if (generateText) generateText.textContent = 'Generate New Route';
            if (generateIcon) generateIcon.style.display = 'inline-block';
            if (generateSpinner) generateSpinner.style.display = 'none';
        }, 2500);
    }

    displayMultiLocationResult(route) {
        const multiResult = document.getElementById('multiResult');
        const multiLocationCount = document.getElementById('multiLocationCount');
        const multiDistance = document.getElementById('multiDistance');
        const multiDuration = document.getElementById('multiDuration');
        const multiRoutes = document.getElementById('multiRoutes');
        
        if (multiLocationCount) multiLocationCount.textContent = `${this.userLocations.length} locations connected`;
        if (multiDistance) multiDistance.textContent = route.distance;
        if (multiDuration) multiDuration.textContent = route.duration;
        if (multiRoutes) multiRoutes.textContent = `${this.userLocations.length - 1}`;
        
        if (multiResult) {
            multiResult.style.display = 'block';
            multiResult.scrollIntoView({ behavior: 'smooth' });
        }
    }

    addCurrentLocation() {
        if (!this.userLocation) {
            this.showToast('Location not available', 'error');
            return;
        }
        
        // Mock adding current location
        const location = {
            id: Date.now(),
            name: 'Current Location',
            address: 'Your current position',
            lat: this.userLocation.lat,
            lng: this.userLocation.lng
        };
        
        this.userLocations.push(location);
        this.updateLocationsList();
        this.showToast('Current location added', 'success');
    }

    handleLocationSearch(query) {
        if (query.length < 3) {
            document.getElementById('searchResults').innerHTML = '';
            return;
        }
        
        // Mock search results
        const mockResults = [
            'Central Park', 'Times Square', 'Brooklyn Bridge', 
            'Museum of Modern Art', 'High Line Park', 'Wall Street'
        ].filter(place => place.toLowerCase().includes(query.toLowerCase()));
        
        const resultsContainer = document.getElementById('searchResults');
        resultsContainer.innerHTML = mockResults.map(place => 
            `<div class="search-result" onclick="window.strideApp.addLocationFromSearch('${place}')">${place}</div>`
        ).join('');
    }

    addLocationFromSearch(placeName) {
        const location = {
            id: Date.now(),
            name: placeName,
            address: `${placeName}, New York, NY`,
            lat: 40.7128 + (Math.random() - 0.5) * 0.1,
            lng: -74.0060 + (Math.random() - 0.5) * 0.1
        };
        
        this.userLocations.push(location);
        this.updateLocationsList();
        this.showToast(`${placeName} added to route`, 'success');
        
        // Clear search
        document.getElementById('locationSearch').value = '';
        document.getElementById('searchResults').innerHTML = '';
    }

    updateLocationsList() {
        const locationsCard = document.getElementById('locationsCard');
        const locationsList = document.getElementById('locationsList');
        const locationCount = document.getElementById('locationCount');
        const totalDistance = document.getElementById('totalDistance');
        const generateBtn = document.getElementById('generateMultiBtn');
        
        if (this.userLocations.length === 0) {
            locationsCard.style.display = 'none';
            if (generateBtn) generateBtn.disabled = true;
            return;
        }
        
        locationsCard.style.display = 'block';
        locationCount.textContent = this.userLocations.length;
        
        // Calculate approximate total distance
        const distance = this.userLocations.length * 0.8 + Math.random() * 0.5;
        totalDistance.textContent = `≈ ${distance.toFixed(1)} km`;
        
        // Create location list HTML
        locationsList.innerHTML = this.userLocations.map((location, index) => `
            <div class="location-item">
                <div class="location-number">${index + 1}</div>
                <div class="location-info">
                    <div class="location-name">${location.name}</div>
                    <div class="location-address">${location.address}</div>
                </div>
                <button class="remove-location" onclick="window.strideApp.removeLocation(${location.id})">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `).join('');
        
        // Enable generate button if we have at least 2 locations
        if (generateBtn) {
            generateBtn.disabled = this.userLocations.length < 2;
        }
    }

    removeLocation(locationId) {
        this.userLocations = this.userLocations.filter(loc => loc.id !== locationId);
        this.updateLocationsList();
        this.showToast('Location removed', 'info');
    }

    addLocation() {
        const locationInput = document.getElementById('location-input');
        const location = locationInput.value.trim();

        if (!location) {
            this.showToast('Please enter a location', 'error');
            return;
        }

        if (this.userLocations.includes(location)) {
            this.showToast('Location already added', 'error');
            return;
        }

        this.userLocations.push(location);
        locationInput.value = '';
        this.updateLocationsList();
        this.showToast('Location added successfully', 'success');
    }

    clearLocations() {
        this.userLocations = [];
        this.updateLocationsList();
        this.showToast('All locations cleared', 'success');
    }

    updateLocationsList() {
        const container = document.getElementById('locations-list');
        container.innerHTML = '';

        this.userLocations.forEach((location, index) => {
            const locationRow = document.createElement('div');
            locationRow.className = 'location-row';
            locationRow.innerHTML = `
                <div class="location-info">
                    <span class="location-number">${index + 1}</span>
                    <span class="location-name">${location}</span>
                </div>
                <button class="remove-location-btn" onclick="strideApp.removeLocation(${index})">
                    ×
                </button>
            `;
            container.appendChild(locationRow);
        });

        // Update button states
        const generateBtn = document.getElementById('generate-multi-btn');
        const clearBtn = document.getElementById('clear-locations-btn');
        
        if (this.userLocations.length >= 2) {
            generateBtn.disabled = false;
            generateBtn.textContent = 'Generate Route';
        } else {
            generateBtn.disabled = true;
            generateBtn.textContent = `Add ${2 - this.userLocations.length} more location${2 - this.userLocations.length > 1 ? 's' : ''}`;
        }

        clearBtn.disabled = this.userLocations.length === 0;
    }

    removeLocation(index) {
        this.userLocations.splice(index, 1);
        this.updateLocationsList();
        this.showToast('Location removed', 'success');
    }

    loadPublicWalks() {
        const container = document.getElementById('public-walks-grid');
        container.innerHTML = '';

        this.publicWalks.forEach(walk => {
            const walkCard = document.createElement('div');
            walkCard.className = 'walk-card';
            walkCard.dataset.walkId = walk.id;
            walkCard.innerHTML = `
                <div class="walk-header">
                    <h3>${walk.title}</h3>
                    <span class="walk-rating">★ ${walk.rating}</span>
                </div>
                <div class="walk-details">
                    <div class="walk-stat">
                        <span class="stat-label">Distance</span>
                        <span class="stat-value">${walk.distance}</span>
                    </div>
                    <div class="walk-stat">
                        <span class="stat-label">Duration</span>
                        <span class="stat-value">${walk.duration}</span>
                    </div>
                    <div class="walk-stat">
                        <span class="stat-label">Difficulty</span>
                        <span class="stat-value">${walk.difficulty}</span>
                    </div>
                </div>
                <div class="walk-location">📍 ${walk.location}</div>
                <div class="walk-description">${walk.description}</div>
                <div class="walk-actions">
                    <button class="btn btn-primary" onclick="strideApp.viewWalkOnMap('${walk.id}')">View Route</button>
                    <button class="btn btn-secondary share-btn">Share</button>
                </div>
            `;
            container.appendChild(walkCard);
        });
    }    generateMockRoute(duration) {
        const distance = (duration * 0.08 + Math.random() * 0.5).toFixed(1); // Roughly 5km/h walking pace
        const waypoints = Math.floor(duration / 10) + Math.floor(Math.random() * 3) + 2; // More waypoints for longer walks
        
        return {
            id: Date.now().toString(),
            distance: `${distance} km`,
            duration: `${duration} min`,
            waypoints: waypoints,
            steps: Math.round(distance * 1300).toLocaleString(), // ~1300 steps per km
            calories: Math.round(duration * 4), // ~4 calories per minute walking
            highlights: this.generateRouteHighlights()
        };
    }

    generateMultiMockRoute(locations) {
        const totalDistance = (locations.length * 1.5 + Math.random() * 2).toFixed(1);
        const steps = Math.round(totalDistance * 1200);

        return {
            id: Date.now().toString(),
            title: `Multi-Location Tour (${locations.length} stops)`,
            startLocation: locations[0],
            locations: locations,
            distance: `${totalDistance} km`,
            duration: `${Math.round(locations.length * 15 + 10)} min`,
            difficulty: 'Moderate',
            steps: steps.toLocaleString(),
            calories: Math.round(steps * 0.04),
            elevation: Math.round(Math.random() * 150 + 30),
            highlights: this.generateRouteHighlights()
        };
    }

    generateRouteHighlights() {
        const highlights = [
            '🌳 Beautiful park scenery',
            '🏛️ Historic landmarks',
            '☕ Cozy cafes along the way',
            '🌊 Scenic waterfront views',
            '🌸 Seasonal flower gardens',
            '🎨 Street art and murals',
            '🏪 Local shops and markets',
            '🌉 Iconic bridges',
            '🦆 Wildlife spotting opportunities',
            '📸 Instagram-worthy photo spots'
        ];

        return highlights.sort(() => 0.5 - Math.random()).slice(0, 3);
    }

    displayRoute(route) {
        this.currentRoute = route;
        
        // Update route info in the modal
        document.getElementById('route-title').textContent = route.title;
        document.getElementById('route-distance').textContent = route.distance;
        document.getElementById('route-duration').textContent = route.duration;
        document.getElementById('route-difficulty').textContent = route.difficulty;
        document.getElementById('route-steps').textContent = route.steps;
        document.getElementById('route-calories').textContent = route.calories;
        document.getElementById('route-elevation').textContent = `${route.elevation}m`;

        // Update highlights
        const highlightsList = document.getElementById('route-highlights');
        highlightsList.innerHTML = '';
        route.highlights.forEach(highlight => {
            const li = document.createElement('li');
            li.textContent = highlight;
            highlightsList.appendChild(li);
        });

        // Show the route on map (mock)
        this.showRouteOnMap(route);

        // Show modal
        document.getElementById('map-modal').classList.add('active');
    }

    showRouteOnMap(route) {
        // Mock map display - in a real app, this would show actual route
        const mapContainer = document.getElementById('map-container');
        mapContainer.innerHTML = `
            <div class="mock-map">
                <div class="map-placeholder">
                    <div class="route-line"></div>
                    <div class="start-marker">📍 Start: ${route.startLocation}</div>
                    ${route.locations ? route.locations.slice(1).map((loc, i) => 
                        `<div class="waypoint-marker" style="top: ${30 + i * 20}%; left: ${40 + i * 15}%">📍 ${loc}</div>`
                    ).join('') : ''}
                    <div class="end-marker">🏁 End</div>
                </div>
            </div>
        `;
    }

    viewWalkOnMap(walkId) {
        const walk = this.publicWalks.find(w => w.id === walkId);
        if (walk) {
            this.displayRoute({
                ...walk,
                steps: Math.round(parseFloat(walk.distance) * 1200).toLocaleString(),
                calories: Math.round(parseFloat(walk.distance) * 1200 * 0.04),
                elevation: Math.round(Math.random() * 100 + 20),
                highlights: this.generateRouteHighlights()
            });
        }
    }

    shareWalk(walkId) {
        const shareCode = this.generateShareCode(walkId);
        document.getElementById('share-code-text').textContent = shareCode;
        document.getElementById('share-modal').classList.add('active');
    }

    generateShareCode(walkId) {
        // Generate a mock share code
        return `STRIDE-${walkId.toUpperCase().slice(0, 8)}`;
    }

    copyShareCode() {
        const shareCode = document.getElementById('share-code-text').textContent;
        navigator.clipboard.writeText(shareCode).then(() => {
            this.showToast('Share code copied to clipboard!', 'success');
            this.closeModals();
        }).catch(() => {
            this.showToast('Failed to copy share code', 'error');
        });
    }

    getCurrentLocation() {
        if (navigator.geolocation) {
            this.showToast('Getting your current location...', 'info');
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    // Mock reverse geocoding
                    const locations = [
                        'Downtown Plaza', 'Central Park', 'Riverside Walk',
                        'City Center', 'Market Square', 'University Campus'
                    ];
                    const randomLocation = locations[Math.floor(Math.random() * locations.length)];
                    document.getElementById('start-location').value = randomLocation;
                    this.showToast('Current location set!', 'success');
                },
                (error) => {
                    this.showToast('Unable to get current location', 'error');
                }
            );
        } else {
            this.showToast('Geolocation not supported', 'error');
        }
    }

    generateMockPublicWalks() {
        return [
            {
                id: 'walk1',
                title: 'Historic Downtown Circuit',
                location: 'Downtown District',
                distance: '3.2 km',
                duration: '45 min',
                difficulty: 'Easy',
                rating: '4.8',
                description: 'A leisurely walk through the historic downtown area with beautiful architecture and charming cafes.'
            },
            {
                id: 'walk2',
                title: 'Riverside Nature Trail',
                location: 'Riverside Park',
                distance: '5.1 km',
                duration: '75 min',
                difficulty: 'Moderate',
                rating: '4.9',
                description: 'Scenic trail along the river with wildlife viewing opportunities and peaceful water views.'
            },
            {
                id: 'walk3',
                title: 'Urban Art & Culture Walk',
                location: 'Arts District',
                distance: '2.8 km',
                duration: '40 min',
                difficulty: 'Easy',
                rating: '4.7',
                description: 'Discover street art, galleries, and cultural landmarks in the vibrant arts district.'
            },
            {
                id: 'walk4',
                title: 'Mountain View Challenge',
                location: 'Hillside Trails',
                distance: '7.3 km',
                duration: '110 min',
                difficulty: 'Challenging',
                rating: '4.6',
                description: 'Challenging hike with rewarding panoramic views of the city and surrounding mountains.'
            },
            {
                id: 'walk5',
                title: 'Coastal Breeze Path',
                location: 'Waterfront',
                distance: '4.5 km',
                duration: '60 min',
                difficulty: 'Moderate',
                rating: '4.9',
                description: 'Refreshing coastal walk with ocean views, lighthouses, and seaside attractions.'
            },
            {
                id: 'walk6',
                title: 'Garden District Stroll',
                location: 'Garden District',
                distance: '2.3 km',
                duration: '35 min',
                difficulty: 'Easy',
                rating: '4.5',
                description: 'Peaceful walk through beautiful residential gardens and tree-lined streets.'
            }
        ];
    }

    initializeMap() {
        // Mock map initialization - in a real app, you'd use Google Maps, Mapbox, etc.
        const mapContainer = document.getElementById('map-container');
        mapContainer.innerHTML = `
            <div class="mock-map">
                <div class="map-placeholder">
                    <div class="map-center">🗺️ Interactive Map</div>
                    <p>Route will be displayed here</p>
                </div>
            </div>
        `;
    }

    showLoader(message = 'Loading...') {
        const loader = document.getElementById('loading-overlay');
        const loadingText = document.getElementById('loading-text');
        loadingText.textContent = message;
        loader.classList.add('active');
    }

    hideLoader() {
        document.getElementById('loading-overlay').classList.remove('active');
    }

    showToast(message, type = 'info') {
        // Create toast element
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.innerHTML = `
            <i class="fas fa-${type === 'success' ? 'check' : type === 'error' ? 'exclamation-triangle' : 'info'}-circle"></i>
            <span>${message}</span>
        `;
        
        // Add to document
        document.body.appendChild(toast);
        
        // Show toast
        setTimeout(() => toast.classList.add('show'), 100);
        
        // Remove toast after 3 seconds
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => document.body.removeChild(toast), 300);
        }, 3000);
    }

    closeModals() {
        document.querySelectorAll('.modal-overlay').forEach(modal => {
            modal.classList.remove('active');
        });
    }

    setupTabs() {
        // Tab navigation
        document.querySelectorAll('.tab-item').forEach(tab => {
            tab.addEventListener('click', (e) => {
                const tabName = e.currentTarget.dataset.tab;
                this.switchTab(tabName);
            });
        });
    }

    switchTab(tabName) {
        // Remove active class from all tabs and content
        document.querySelectorAll('.tab-item').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });

        // Add active class to selected tab and content
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
        document.getElementById(`${tabName}-tab`).classList.add('active');
        
        this.currentTab = tabName;
    }

    requestLocation() {
        if (this.isGettingLocation) return;
        
        this.isGettingLocation = true;
        this.updateLocationStatus('Getting Location...', 'orange', true);
        
        if (!navigator.geolocation) {
            this.updateLocationStatus('Location not supported', 'red', false);
            this.isGettingLocation = false;
            return;
        }

        // Options for geolocation
        const options = {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 300000 // 5 minutes
        };

        navigator.geolocation.getCurrentPosition(
            (position) => {
                this.handleLocationSuccess(position);
            },
            (error) => {
                this.handleLocationError(error);
            },
            options
        );
    }

    handleLocationSuccess(position) {
        this.userLocation = {
            lat: position.coords.latitude,
            lng: position.coords.longitude,
            accuracy: position.coords.accuracy
        };
        
        this.isGettingLocation = false;
        
        // Update UI
        this.updateLocationStatus('Location found', 'green', false);
        this.enableGenerateButton();
        
        // Update accuracy display
        const accuracyElement = document.getElementById('locationAccuracy');
        if (accuracyElement) {
            accuracyElement.textContent = `Accuracy: ±${Math.round(position.coords.accuracy)}m`;
        }
    }

    handleLocationError(error) {
        this.isGettingLocation = false;
        let errorMessage = 'Location unavailable';
        
        switch(error.code) {
            case error.PERMISSION_DENIED:
                errorMessage = 'Location access denied';
                break;
            case error.POSITION_UNAVAILABLE:
                errorMessage = 'Location unavailable';
                break;
            case error.TIMEOUT:
                errorMessage = 'Location request timeout';
                break;
        }
        
        this.updateLocationStatus(errorMessage, 'red', false);
        
        // Still enable the button to allow manual location entry or demo mode
        this.enableGenerateButton();
    }    updateLocationStatus(message, color, showSpinner) {
        const statusCard = document.getElementById('locationStatus');
        const statusTitle = statusCard?.querySelector('.status-title');
        const statusDot = statusCard?.querySelector('.status-dot');
        const spinner = document.getElementById('locationSpinner');
        
        if (statusTitle) statusTitle.textContent = message;
        if (statusDot) {
            statusDot.className = `status-dot ${color}`;
        }
        if (spinner) {
            spinner.style.display = showSpinner ? 'block' : 'none';
        }
    }

    enableGenerateButton() {
        const generateBtn = document.getElementById('generateWalkBtn');
        if (generateBtn) {
            generateBtn.disabled = false;
        }
    }

    displayWalkResult(route) {
        const walkResult = document.getElementById('walkResult');
        const walkDistance = document.getElementById('walkDistance');
        const walkDuration = document.getElementById('walkDuration');
        const walkWaypoints = document.getElementById('walkWaypoints');
        
        if (walkDistance) walkDistance.textContent = route.distance;
        if (walkDuration) walkDuration.textContent = route.duration;
        if (walkWaypoints) walkWaypoints.textContent = route.waypoints;
        
        if (walkResult) {
            walkResult.style.display = 'block';
            walkResult.scrollIntoView({ behavior: 'smooth' });
        }
    }

    // Global function to show map (called from HTML)
    showMap(type) {
        this.showMapModal(type);
    }

    // Add the showMapModal method to the StrideApp class
    showMapModal(type) {
        // Simple implementation - could be enhanced with actual map
        alert(`Showing ${type} route on map!\n\nRoute Details:\n${JSON.stringify(this.currentRoute, null, 2)}`);
    }

    showRouteModal(routeType) {
        if (!this.currentRoute) {
            this.showToast('No route available to display', 'error');
            return;
        }

        const modal = document.getElementById('mapModal');
        const mapTitle = document.getElementById('mapTitle');
        const modalDistance = document.getElementById('modalDistance');
        const modalDuration = document.getElementById('modalDuration');
        const modalWaypoints = document.getElementById('modalWaypoints');
        const routeHighlights = document.getElementById('routeHighlights');
        
        // Update modal content
        if (mapTitle) {
            mapTitle.textContent = routeType === 'random' ? 'Random Walk Route' : 'Multi-Location Route';
        }
        
        if (modalDistance) modalDistance.textContent = this.currentRoute.distance;
        if (modalDuration) modalDuration.textContent = this.currentRoute.duration;
        if (modalWaypoints) {
            modalWaypoints.textContent = this.currentRoute.waypoints ? 
                `${this.currentRoute.waypoints} stops` : 'Multiple stops';
        }
        
        // Add route highlights
        if (routeHighlights && this.currentRoute.highlights) {
            routeHighlights.innerHTML = `
                <h5>Route Highlights</h5>
                <div class="highlights-list">
                    ${this.currentRoute.highlights.map(highlight => 
                        `<span class="highlight-tag">${highlight}</span>`
                    ).join('')}
                </div>
            `;
        }
        
        // Show modal
        if (modal) {
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
    }

    closeMapModal() {
        const modal = document.getElementById('mapModal');
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    }

    startNavigation() {
        this.showToast('Navigation started! 🧭', 'success');
        this.closeMapModal();
        // Here you could integrate with actual navigation apps
        // window.open(`https://maps.google.com/maps?daddr=${destination}`);
    }

    shareRoute() {
        if (!this.currentRoute) {
            this.showToast('No route to share', 'error');
            return;
        }
        
        const shareData = {
            title: 'Check out my walking route!',
            text: `I generated a ${this.currentRoute.duration} walking route (${this.currentRoute.distance}) using Stride app!`,
            url: window.location.href
        };
        
        if (navigator.share) {
            navigator.share(shareData).then(() => {
                this.showToast('Route shared!', 'success');
            }).catch(() => {
                this.fallbackShare(shareData);
            });
        } else {
            this.fallbackShare(shareData);
        }
    }

    fallbackShare(shareData) {
        // Copy to clipboard as fallback
        const text = `${shareData.text}\n${shareData.url}`;
        navigator.clipboard.writeText(text).then(() => {
            this.showToast('Route copied to clipboard!', 'success');
        }).catch(() => {
            this.showToast('Unable to share route', 'error');
        });
    }

    downloadRoute() {
        if (!this.currentRoute) {
            this.showToast('No route to download', 'error');
            return;
        }
        
        // Generate mock GPX data
        const gpxData = this.generateMockGPX(this.currentRoute);
        const blob = new Blob([gpxData], { type: 'application/gpx+xml' });
        const url = URL.createObjectURL(blob);
        
        const a = document.createElement('a');
        a.href = url;
        a.download = `stride-route-${Date.now()}.gpx`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        
        this.showToast('Route downloaded as GPX!', 'success');
    }

    generateMockGPX(route) {
        const timestamp = new Date().toISOString();
        return `<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Stride Walking App">
    <metadata>
        <name>Stride Walking Route</name>
        <desc>Generated walking route - ${route.distance}, ${route.duration}</desc>
        <time>${timestamp}</time>
    </metadata>
    <trk>
        <name>Walking Route</name>
        <trkseg>
            <trkpt lat="40.7128" lon="-74.0060">
                <ele>10</ele>
                <time>${timestamp}</time>
            </trkpt>
            <trkpt lat="40.7138" lon="-74.0070">
                <ele>12</ele>
                <time>${timestamp}</time>
            </trkpt>
            <trkpt lat="40.7148" lon="-74.0080">
                <ele>15</ele>
                <time>${timestamp}</time>
            </trkpt>
        </trkseg>
    </trk>
</gpx>`;
    }
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.strideApp = new StrideApp();
});

// Add some utility functions for better UX
document.addEventListener('keydown', (e) => {
    // Close modals with Escape key
    if (e.key === 'Escape') {
        window.strideApp?.closeModals();
    }
});

// Handle form submissions
document.addEventListener('submit', (e) => {
    e.preventDefault();
});

// Add input validation and formatting
document.addEventListener('input', (e) => {
    if (e.target.id === 'duration-slider') {
        const value = e.target.value;
        const label = document.querySelector('label[for="duration-slider"] .slider-value');
        if (label) {
            label.textContent = `${value} minutes`;
        }
    }
});

// Add touch and accessibility improvements
document.addEventListener('touchstart', () => {}, { passive: true });

// Service Worker registration for PWA-like experience (optional)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        // Could register a service worker here for offline support
        console.log('Stride Web Demo loaded successfully');
    });
}

// Global functions for HTML onclick handlers
function showMap(routeType) {
    window.strideApp?.showRouteModal(routeType);
}

function closeMapModal() {
    window.strideApp?.closeMapModal();
}

function startNavigation() {
    window.strideApp?.startNavigation();
}

function shareRoute() {
    window.strideApp?.shareRoute();
}

function downloadRoute() {
    window.strideApp?.downloadRoute();
}

function shareWalk() {
    window.strideApp?.shareRoute();
}
