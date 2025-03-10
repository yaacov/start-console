import os
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

@pytest.fixture(scope="module")
def setup_browser():
    """Set up Selenium WebDriver with options."""
    chrome_options = Options()
    chrome_options.add_argument("--ignore-certificate-errors")  # Ignore SSL/TLS errors
    chrome_options.add_argument("--allow-insecure-localhost")  # Allow localhost with self-signed certs

    driver = webdriver.Chrome(options=chrome_options)
    yield driver  # Provide the driver to the test
    driver.quit()  # Cleanup after tests

def test_login(setup_browser):
    """Automated test for login functionality."""

    # Read environment variables
    PASSWORD = os.getenv("PASSWORD")
    URL = os.getenv("URL")

    assert PASSWORD, "PASSWORD environment variable is not set."
    assert URL, "URL environment variable is not set."

    driver = setup_browser
    driver.get(URL)

    # Wait for input fields
    wait = WebDriverWait(driver, 15)

    # Enter username
    username_input = wait.until(EC.presence_of_element_located((By.ID, "inputUsername")))
    username_input.send_keys("kubeadmin")

    # Enter password
    password_input = driver.find_element(By.ID, "inputPassword")
    password_input.send_keys(PASSWORD)

    # Click login button
    submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
    submit_button.click()

    # Wait for login success (URL change)
    wait.until(EC.url_changes(driver.current_url))

    # Verify login succeeded
    assert "dashboard" in driver.current_url.lower(), "Login failed, dashboard not loaded."
