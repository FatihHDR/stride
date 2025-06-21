// Stride Web Demo - JavaScript Implementation
// Modern walking route generator with interactive features

class StrideApp {
    constructor() {
        this.currentView = 'random-walk';
        this.map = null;
        this.markers = [];
        this.currentRoute = null;
        this.publicWalks = this.generateMockPublicWalks();
        this.userLocations = [];
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.showView('random-walk');
        this.updateTabSelection();
        this.initializeMap();
    }

    setupEventListeners() {
        // Tab navigation
        document.querySelectorAll('.tab-button').forEach(button => {
            button.addEventListener('click', (e) => {
                const view = e.target.dataset.view;
                this.showView(view);
                this.updateTabSelection();
            });
        });

        // Generate Random Walk
        document.getElementById('generate-random-btn').addEventListener('click', () => {
            this.generateRandomWalk();
        });

        // Generate Multi-Location Walk
        document.getElementById('generate-multi-btn').addEventListener('click', () => {
            this.generateMultiLocationWalk();
        });

        // Add Location
        document.getElementById('add-location-btn').addEventListener('click', () => {
            this.addLocation();
        });

        // Clear Locations
        document.getElementById('clear-locations-btn').addEventListener('click', () => {
            this.clearLocations();
        });

        // Modal close buttons
        document.querySelectorAll('.close-modal').forEach(btn => {
            btn.addEventListener('click', () => {
                this.closeModals();
            });
        });

        // Share buttons
        document.querySelectorAll('.share-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const walkId = e.target.closest('.walk-card').dataset.walkId;
                this.shareWalk(walkId);
            });
        });

        // Copy share code
        document.getElementById('copy-share-code').addEventListener('click', () => {
            this.copyShareCode();
        });

        // Current location button
        document.getElementById('current-location-btn').addEventListener('click', () => {
            this.getCurrentLocation();
        });

        // Modal overlay clicks
        document.querySelectorAll('.modal-overlay').forEach(overlay => {
            overlay.addEventListener('click', (e) => {
                if (e.target === overlay) {
                    this.closeModals();
                }
            });
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
    }

    generateRandomWalk() {
        const duration = document.getElementById('duration-slider').value;
        const difficulty = document.getElementById('difficulty-select').value;
        const startLocation = document.getElementById('start-location').value;

        if (!startLocation.trim()) {
            this.showToast('Please enter a starting location', 'error');
            return;
        }

        this.showLoader('Generating your perfect walking route...');

        // Simulate API call
        setTimeout(() => {
            const route = this.generateMockRoute(startLocation, duration, difficulty);
            this.displayRoute(route);
            this.hideLoader();
            this.showToast('Route generated successfully!', 'success');
        }, 2000);
    }

    generateMultiLocationWalk() {
        if (this.userLocations.length < 2) {
            this.showToast('Please add at least 2 locations', 'error');
            return;
        }

        this.showLoader('Creating multi-location route...');

        setTimeout(() => {
            const route = this.generateMultiMockRoute(this.userLocations);
            this.displayRoute(route);
            this.hideLoader();
            this.showToast('Multi-location route created!', 'success');
        }, 2500);
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
    }

    generateMockRoute(startLocation, duration, difficulty) {
        const distances = {
            'easy': { min: 1.5, max: 3.0 },
            'moderate': { min: 2.5, max: 5.0 },
            'challenging': { min: 4.0, max: 8.0 }
        };

        const difficultyData = distances[difficulty];
        const distance = (difficultyData.min + (difficultyData.max - difficultyData.min) * Math.random()).toFixed(1);
        const steps = Math.round(distance * 1200);

        return {
            id: Date.now().toString(),
            title: `${difficulty.charAt(0).toUpperCase() + difficulty.slice(1)} Walk from ${startLocation}`,
            startLocation,
            distance: `${distance} km`,
            duration: `${duration} min`,
            difficulty: difficulty.charAt(0).toUpperCase() + difficulty.slice(1),
            steps: steps.toLocaleString(),
            calories: Math.round(steps * 0.04),
            elevation: Math.round(Math.random() * 100 + 20),
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
        const toast = document.getElementById('toast');
        const toastMessage = document.getElementById('toast-message');
        
        toastMessage.textContent = message;
        toast.className = `toast ${type}`;
        toast.classList.add('show');

        setTimeout(() => {
            toast.classList.remove('show');
        }, 3000);
    }

    closeModals() {
        document.querySelectorAll('.modal-overlay').forEach(modal => {
            modal.classList.remove('active');
        });
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
