const products = [
    {
        name: "Black and Gray Athletic Cotton Socks - 6 Pairs",
        image: "images/products/athletic-cotton-socks-6-pairs.jpg",
        // image: "tree.jpeg",
        rating: "images/ratings/rating-45.png",
        ratingCount: 87,
        price: 10.90
    },
    {
        name: "Intermediate Size Basketball",
        image: "images/products/intermediate-composite-basketball.jpg",
        rating: "images/ratings/rating-40.png",
        ratingCount: 127,
        price: 20.95
    },
    {
        name: "Adults Plain Cotton T-Shirt - 2 Pack",
        image: "images/products/adults-plain-cotton-tshirt-2-pack-teal.jpg",
        rating: "images/ratings/rating-45.png",
        ratingCount: 56,
        price: 7.99
    },
    {
        name: "Black 2-slot Toaster",
        image: "images/products/black-2-slot-toaster.jpg",
        rating: "images/ratings/rating-45.png",
        ratingCount: 45,
        price: 29.50
    },
    {
        name: "Coffeemaker with Glass Carafe - Black",
        image: "images/products/coffeemaker-with-glass-carafe-black.jpg",
        rating: "images/ratings/rating-45.png",
        ratingCount: 119,
        price: 33.90
    },
    {
        name: "Bathroom Rug",
        image: "images/products/bathroom-rug.jpg",
        rating: "images/ratings/rating-45.png",
        ratingCount: 37,
        price: 12.55
    },
    {
        name: "Blackout Curtain Set - Beige",
        image: "images/products/blackout-curtain-set-beige.webp",
        rating: "images/ratings/rating-45.png",
        ratingCount: 89,
        price: 42.99
    },
    {
        name: "Electric Glass and Steel Hot Water Kettle",
        image: "images/products/electric-glass-and-steel-hot-water-kettle.webp",
        rating: "images/ratings/rating-45.png",
        ratingCount: 27,
        price: 27.89
    },
    {
        name: "Luxury Towel Set - 6 Pieces",
        image: "images/products/luxury-tower-set-6-piece.jpg",
        rating: "images/ratings/rating-45.png",
        ratingCount: 19,
        price: 19.99
    },
    {
        name: "Liquid Laundry Detergent",
        image: "images/products/liquid-laundry-detergent-plain.jpg",
        rating: "images/ratings/rating-45.png",
        ratingCount: 33,
        price: 14.99
    },
    {
        name: "Men Navigator Sunglasses - Brown",
        image: "images/products/men-navigator-sunglasses-brown.jpg",
        rating: "images/ratings/rating-45.png",
        ratingCount: 67,
        price: 35.99
    },
    {
        name: "Women Chunky Beanie - Gray",
        image: "images/products/women-chunky-beanie-gray.webp",
        rating: "images/ratings/rating-45.png",
        ratingCount: 72,
        price: 23.99
    }
];

document.addEventListener("DOMContentLoaded", function () {
    initializeProducts();
});

function initializeProducts() {
    const productsContainer = document.getElementById("productsContainer");
    productsContainer.innerHTML = "";

    products.forEach((product, index) => {
        appendProductToContainer(product, index);
    });

    productsContainer.addEventListener("click", function (event) {
        const productContainer = event.target.closest(".product-container");
        if (productContainer) {
            // If the click is on any part of the product container, open the modal
            openModal(productContainer);
        }
    });
}


function performSearch() {
    const searchInput = document.getElementById("searchInput").value.toLowerCase();
    const productsContainer = document.getElementById("productsContainer");
    productsContainer.innerHTML = "";

    const matchingProducts = products.filter(product => product.name.toLowerCase().includes(searchInput));

    // sort the matching products
    matchingProducts.sort((a, b) => a.price - b.price);

    matchingProducts.forEach(product => {
        appendProductToContainer(product);
    });
}

function performFilter() {
    const minPrice = parseFloat(document.getElementById("minPriceInput").value) || 0;
    const maxPrice = parseFloat(document.getElementById("maxPriceInput").value) || Number.MAX_VALUE;
    const minRatingCount = parseInt(document.getElementById("minRatingInput").value) || 0;

    const filteredProducts = products.filter(product => {
        return product.price >= minPrice && product.price <= maxPrice && product.ratingCount >= minRatingCount;
    });

    // Sort the filtered products by price
    const sortByPrice = document.getElementById("sortByPrice").value;
    if (sortByPrice === "asc") {
        filteredProducts.sort((a, b) => a.price - b.price);
    } else if (sortByPrice === "desc") {
        filteredProducts.sort((a, b) => b.price - a.price);
    }

    const productsContainer = document.getElementById("productsContainer");
    productsContainer.innerHTML = "";

    filteredProducts.forEach(product => {
        appendProductToContainer(product);
    });
}

function resetFilters() {

    document.getElementById("minPriceInput").value = "";
    document.getElementById("maxPriceInput").value = "";
    document.getElementById("minRatingInput").value = "";

    initializeProducts();
}

function appendProductToContainer(product, index) {
    const productsContainer = document.getElementById("productsContainer");

    const productContainer = document.createElement("div");
    productContainer.className = "product-container";
    productContainer.innerHTML = `
        <div class="product-image-container">
            <img class="product-image" src="${product.image}">
        </div>
        <div class="product-name limit-text-to-2-lines">${product.name}</div>
        <div class="product-rating-container">
            <img class="product-rating-stars" src="${product.rating}">
            <div class="product-rating-count link-primary">${product.ratingCount}</div>
        </div>
        <div class="product-price">$${product.price.toFixed(2)}</div>
        <div class="product-quantity-container">
            <select>
                <option selected value="1">1</option>
                <option value="2">2</option>
                <!-- Add more quantity options if needed -->
            </select>
        </div>
        <div class="product-spacer"></div>
        <button class="add-to-cart-button button-primary" onclick="addToCart()">
            Add to Cart
        </button>
    `;

    productsContainer.appendChild(productContainer);
}

function openModal(productContainer) {
    const product = getProductDetails(productContainer);
    const modal = document.getElementById("productModal");
    const modalDetails = document.getElementById("modalProductDetails");

    modalDetails.innerHTML = `
        <div class="product-container">
            <div class="product-image-container">
                <img class="product-image" src="${product.image}">
            </div>
            <div class="product-details">
                <h2>${product.name}</h2>
                <p>Rating: ${product.ratingCount} </p>
                <p>Price: $${product.price.toFixed(2)}</p>
            </div>
            <div class="product-quantity-container">
                <select>
                    <option selected value="1">1</option>
                    <option value="2">2</option>
                    <option value="3">3</option>
                    <option value="4">4</option>
                    <option value="5">5</option>
                    <option value="6">6</option>
                    <option value="7">7</option>
                    <option value="8">8</option>
                    <option value="9">9</option>
                    <option value="10">10</option>
                </select>
            </div>
            <div class="product-spacer"></div>
        </div>
    `;

    modal.style.display = "block";
    document.body.style.backgroundColor = "rgba(0, 0, 0, 0.5)";
}


function getProductDetails(productContainer) {
    const product = {};

    product.name = productContainer.querySelector(".product-name").textContent;
    product.image = productContainer.querySelector(".product-image").src;
    product.ratingCount = parseInt(productContainer.querySelector(".product-rating-count").textContent);

    const priceText = productContainer.querySelector(".product-price").textContent;
    product.price = parseFloat(priceText.replace("$", ""));

    product.rating = productContainer.querySelector(".product-rating-stars").src;


    return product;
}

function closeModal() {
    const modal = document.getElementById("productModal");
    modal.style.display = "none";
    document.body.style.backgroundColor = "white";
}

function addToCart() {
    alert("Product added to cart!");
    closeModal();
}

function scrollToTop() {
    window.scrollTo({
        top: 0,
        behavior: "smooth" // Optional: Adds a smooth scrolling effect
    });
}