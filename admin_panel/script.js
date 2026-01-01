const API_BASE = 'http://localhost:5000/api';

/* =========================
   AUTH HELPERS
========================= */
function getAuthHeaders() {
  const token = localStorage.getItem('adminToken');
  if (!token) {
    alert('Session expired. Please login again.');
    window.location.href = 'login.html';
    return {};
  }

  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
  };
}

function checkAdminAuth() {
  const token = localStorage.getItem('adminToken');
  if (!token) {
    window.location.href = 'login.html';
  }
}

/* =========================
   ADMIN LOGIN
========================= */
async function adminLogin() {
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  const errorMsg = document.getElementById('errorMsg');

  errorMsg.innerText = '';

  try {
    const res = await fetch(`${API_BASE}/admin/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    const data = await res.json();

    if (!res.ok) {
      errorMsg.innerText = data.message;
      return;
    }

    localStorage.setItem('adminToken', data.token);
    window.location.href = 'index.html';

  } catch (err) {
    errorMsg.innerText = 'Server error';
  }
}

/* =========================
   FETCH ALL ORDERS
========================= */
async function fetchOrders() {
  try {
    const res = await fetch(`${API_BASE}/orders`, {
      headers: getAuthHeaders(),
    });

    const orders = await res.json();
    const tableBody = document.getElementById('ordersTableBody');
    tableBody.innerHTML = '';

    if (!orders.length) {
      tableBody.innerHTML =
        '<tr><td colspan="5">No orders found</td></tr>';
      return;
    }

    orders.forEach(order => {
      tableBody.innerHTML += `
        <tr>
          <td>${order.customerName}</td>
          <td>${order.customerPhone}</td>
          <td>Rs ${order.totalAmount}</td>
          <td>${order.status}</td>
          <td>
            <button onclick="viewOrder('${order._id}')">View</button>
            <button onclick="updateStatus('${order._id}')">Delivered</button>
          </td>
        </tr>
      `;
    });
  } catch (err) {
    console.error(err);
  }
}

/* =========================
   QUICK STATUS UPDATE
========================= */
async function updateStatus(orderId) {
  try {
    const res = await fetch(`${API_BASE}/orders/${orderId}/status`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify({ status: 'Delivered' }),
    });

    if (!res.ok) {
      const data = await res.json();
      return alert(data.message);
    }

    alert('Order delivered');
    fetchOrders();
  } catch (err) {
    console.error(err);
  }
}

/* =========================
   ORDER DETAILS
========================= */
function viewOrder(id) {
  window.location.href = `order-detail.html?id=${id}`;
}

async function loadOrderDetails() {
  const id = new URLSearchParams(window.location.search).get('id');

  const res = await fetch(`${API_BASE}/orders`, {
    headers: getAuthHeaders(),
  });

  const orders = await res.json();
  const order = orders.find(o => o._id === id);

  document.getElementById('orderInfo').innerHTML = `
    <p><b>Name:</b> ${order.customerName}</p>
    <p><b>Phone:</b> ${order.customerPhone}</p>
    <p><b>Address:</b> ${order.customerAddress}</p>
    <p><b>Total:</b> Rs ${order.totalAmount}</p>
  `;

  const table = document.getElementById('productsTable');
  table.innerHTML = '';

  order.products.forEach(p => {
    table.innerHTML += `
      <tr>
        <td>${p.product?.name || 'Deleted product'}</td>
        <td>${p.quantity}</td>
      </tr>
    `;
  });

  document.getElementById('statusSelect').value = order.status;
}

/* =========================
   UPDATE FROM DETAIL PAGE
========================= */
async function updateOrder() {
  const id = new URLSearchParams(window.location.search).get('id');
  const status = document.getElementById('statusSelect').value;

  const res = await fetch(`${API_BASE}/orders/${id}/status`, {
    method: 'PUT',
    headers: getAuthHeaders(),
    body: JSON.stringify({ status }),
  });

  if (!res.ok) {
    const data = await res.json();
    return alert(data.message);
  }

  alert('Order updated');
  window.location.href = 'orders.html';
}

/* =========================
   DASHBOARD
========================= */
async function loadDashboard() {
  const res = await fetch(`${API_BASE}/orders`, {
    headers: getAuthHeaders(),
  });

  const orders = await res.json();

  document.getElementById('totalOrders').innerText = orders.length;
  document.getElementById('pendingOrders').innerText =
    orders.filter(o => o.status === 'Pending').length;
  document.getElementById('deliveredOrders').innerText =
    orders.filter(o => o.status === 'Delivered').length;
  document.getElementById('totalRevenue').innerText =
    orders
      .filter(o => o.status === 'Delivered')
      .reduce((sum, o) => sum + o.totalAmount, 0);
}

/* =========================
   FETCH PRODUCTS (ADMIN)
========================= */
async function fetchProducts() {
  try {
    const res = await fetch(`${API_BASE}/products`, {
      headers: getAuthHeaders(),
    });

    const products = await res.json();
    const table = document.getElementById('productsTable');
    table.innerHTML = '';

    products.forEach(p => {
      table.innerHTML += `
        <tr>
          <td>${p.name}</td>
          <td>Rs ${p.price}</td>
          <td>${p.category}</td>
          <td>${p.subCategory}</td>
          <td>
            <button onclick="editProduct('${p._id}')">Edit</button>
            <button onclick="deleteProduct('${p._id}')">Delete</button>
          </td>
        </tr>
      `;
    });

  } catch (err) {
    console.error(err);
  }
}

/* =========================
   ADD / UPDATE PRODUCT
========================= */
async function saveProduct() {
  const id = new URLSearchParams(window.location.search).get('id');

  // ✅ EXPLICIT INPUT REFERENCES (FIX)
  const nameInput = document.getElementById('name');
  const priceInput = document.getElementById('price');
  const discountInput = document.getElementById('discount');
  const categoryInput = document.getElementById('category');
  const subCategoryInput = document.getElementById('subCategory');
  // const imageInput = document.getElementById('image'); // Removed
  const descriptionInput = document.getElementById('description');
  const stockInput = document.getElementById('stock');
  const fulldescriptionInput = document.getElementById('fulldescription');

  // 🔒 VALIDATION
  if (
    !nameInput.value.trim() ||
    !priceInput.value ||
    !categoryInput.value.trim() ||
    !subCategoryInput.value.trim()
  ) {
    alert('Please fill all required fields');
    return;
  }

  // Determine if we are updating (PUT) or creating (POST)
  // Note: HTML forms with file upload should use FormData
  const formData = new FormData();
  formData.append('name', nameInput.value.trim());
  formData.append('price', priceInput.value);
  formData.append('discount', discountInput.value || 0);
  formData.append('category', categoryInput.value.trim());
  formData.append('subCategory', subCategoryInput.value.trim());
  formData.append('description', descriptionInput.value.trim());
  formData.append('stock', stockInput.value);
  formData.append('fulldescription', fulldescriptionInput.value.trim());

  // Handle Image Files
  const fileInput = document.getElementById('imageInput');
  if (fileInput.files.length > 0) {
    for (let i = 0; i < fileInput.files.length; i++) {
      formData.append('images', fileInput.files[i]);
    }
  }

  // Handle Manual Image URL
  const manualImageInput = document.getElementById('manualImageInput');
  if (manualImageInput && manualImageInput.value.trim()) {
    formData.append('manualImages', manualImageInput.value.trim());
  }

  // If editing, we might want to keep existing images or replace them.
  // For simplicity in this upgrade, new files will replace old ones or start fresh.

  const url = id
    ? `${API_BASE}/products/${id}`
    : `${API_BASE}/products`;

  const method = id ? 'PUT' : 'POST';

  // HEADERS: Do NOT set Content-Type to application/json when sending FormData.
  // The browser sets it automatically with the boundary.
  const headers = getAuthHeaders();
  delete headers['Content-Type']; // Remove application/json

  try {
    const res = await fetch(url, {
      method,
      headers: headers,
      body: formData,
    });

    const data = await res.json();

    if (!res.ok) {
      alert(data.message || 'Failed to save product');
      return;
    }

    alert(id ? 'Product updated successfully' : 'Product added successfully');
    window.location.href = 'products.html';

  } catch (err) {
    console.error('SAVE PRODUCT ERROR:', err);
    alert('Server error while saving product');
  }
}

/* =========================
   EDIT PRODUCT
========================= */
function editProduct(id) {
  window.location.href = `product-form.html?id=${id}`;
}

async function loadProductForEdit() {
  const id = new URLSearchParams(window.location.search).get('id');
  if (!id) return;

  document.getElementById('formTitle').innerText = 'Edit Product';

  const res = await fetch(`${API_BASE}/products/${id}`);
  const p = await res.json();

  name.value = p.name;
  price.value = p.price;
  discount.value = p.discount;
  category.value = p.category;
  subCategory.value = p.subCategory;
  const manualImageInput = document.getElementById('manualImageInput');
  if (manualImageInput) {
    // If the first image is a URL, show it. If it's a list, join them? 
    // For simplicity, just show the first one or empty.
    manualImageInput.value = (p.image && Array.isArray(p.image)) ? p.image.join(', ') : '';
  }

  // image.value = (p.images || []).join(', '); // Old text area
  // For file input, we cannot set value programmatically for security.
  // We can maybe show a preview of existing images here if we added a preview container.
  // For now, leaving it empty means "no change" or "new upload overrides".
  description.value = p.description;
}

/* =========================
   DELETE PRODUCT
========================= */
async function deleteProduct(id) {
  if (!confirm('Delete this product?')) return;

  const res = await fetch(`${API_BASE}/products/${id}`, {
    method: 'DELETE',
    headers: getAuthHeaders(),
  });

  if (!res.ok) {
    alert('Delete failed');
    return;
  }

  alert('Product deleted');
  fetchProducts();
}
