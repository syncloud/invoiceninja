import { expect, type Locator, type Page } from '@playwright/test'
import { env } from './env'

function exact(text: string): RegExp {
  return new RegExp(`^\\s*${text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\s*\\*?\\s*$`)
}

export function sidebar(page: Page): Locator {
  return page.locator('[data-cy="navigationBar"]')
}

export function topbar(page: Page): Locator {
  return page.locator('[data-cy="topNavbar"]')
}

export function title(page: Page, text: string): Locator {
  return topbar(page).getByRole('heading', { name: text, exact: true })
}

function save(page: Page): Locator {
  return topbar(page).getByRole('button', { name: 'Save', exact: true })
}

function field(page: Page, label: string): Locator {
  return page
    .locator('dt')
    .filter({ hasText: exact(label) })
    .locator('xpath=following-sibling::dd[1]')
    .locator('input')
    .first()
}

async function enter(input: Locator, value: string): Promise<void> {
  await input.fill(value)
  await input.blur()
}

function labelled(scope: Locator, label: string): Locator {
  return scope.locator('label').filter({ hasText: exact(label) }).locator('xpath=..')
}

async function choose(scope: Locator, label: string, search: string, option: string): Promise<void> {
  const select = labelled(scope, label)
  await select.getByRole('combobox').fill(search)
  await select.getByRole('combobox').press('Enter')
  await expect(select.getByText(option, { exact: true })).toBeVisible()
}

function welcome(page: Page): Locator {
  return page.getByRole('dialog', { name: 'Welcome to Invoice Ninja' })
}

async function visibleWithin(locator: Locator, timeout: number): Promise<boolean> {
  try {
    await locator.waitFor({ state: 'visible', timeout })
    return true
  } catch {
    return false
  }
}

export async function login(page: Page): Promise<void> {
  await page.goto('/')
  await page.locator('input[name="username"]').fill(env('PLAYWRIGHT_DEVICE_USER'))
  await page.locator('#password').fill(env('PLAYWRIGHT_DEVICE_PASSWORD'))
  await page.getByRole('button', { name: 'Login', exact: true }).click()
  await expect(sidebar(page)).toBeVisible()
}

export async function nameCompany(page: Page, name: string): Promise<void> {
  const dialog = welcome(page)
  if (!(await visibleWithin(dialog, 15_000))) {
    return
  }
  await enter(labelled(dialog, 'Company Name').locator('input'), name)
  await dialog.getByRole('button', { name: 'Save', exact: true }).click()
  await expect(dialog).toBeHidden()
}

export async function openSettings(page: Page): Promise<void> {
  await sidebar(page).getByRole('link', { name: 'Settings', exact: true }).click()
  await expect(page.getByText('Basic Settings', { exact: true })).toBeVisible()
}

export async function openPayments(page: Page): Promise<void> {
  await sidebar(page).getByRole('link', { name: 'Payments', exact: true }).click()
  await expect(title(page, 'Payments')).toBeVisible()
}

export async function createClient(page: Page, name: string): Promise<void> {
  await sidebar(page).locator('a[href="/clients/create"]').click()
  await expect(title(page, 'New Client')).toBeVisible()
  await enter(field(page, 'Name'), name)
  await save(page).click()
  await expect(title(page, name)).toBeVisible()
}

export async function createProduct(page: Page, item: string, price: string): Promise<void> {
  await sidebar(page).locator('a[href="/products/create"]').click()
  await expect(title(page, 'New Product')).toBeVisible()
  await enter(field(page, 'Item'), item)
  await enter(field(page, 'Price'), price)
  await save(page).click()
  await expect(title(page, 'Edit Product')).toBeVisible()
}

export async function createInvoice(page: Page, client: string, product: string): Promise<void> {
  await sidebar(page).locator('a[href="/invoices/create"]').click()
  await expect(title(page, 'New Invoice')).toBeVisible()
  await page.getByRole('option', { name: client, exact: true }).first().click()
  await page.getByText('Add Item', { exact: true }).click()
  await page.locator('table [data-cy="comboboxInput"]').first().click()
  await page.locator('[data-combobox-element-id]').getByText(product, { exact: true }).first().click()
  await save(page).click()
  await expect(title(page, 'Edit Invoice')).toBeVisible()
}

export async function addCompany(page: Page, name: string): Promise<void> {
  const switcher = page.locator('[data-cy="companyDropdown"]')
  await switcher.getByRole('img', { name: 'Company logo' }).first().click()
  await page.getByText('Add Company', { exact: true }).click()
  const confirm = page.getByRole('dialog', { name: 'Add Company' })
  await confirm.getByRole('button', { name: 'Yes', exact: true }).click()
  const dialog = welcome(page)
  await expect(dialog).toBeVisible()
  await enter(labelled(dialog, 'Company Name').locator('input'), name)
  await choose(dialog, 'Currency', 'Bermudian', 'Bermudian Dollar (BMD)')
  await choose(dialog, 'Language', 'English - United Kingdom', 'English - United Kingdom')
  await dialog.getByRole('button', { name: 'Save', exact: true }).click()
  await expect(dialog).toBeHidden()
  await expect(switcher).toContainText(name)
}

export async function openClients(page: Page): Promise<void> {
  await sidebar(page).getByRole('link', { name: 'Clients', exact: true }).click()
  await expect(title(page, 'Clients')).toBeVisible()
}

export async function openProducts(page: Page): Promise<void> {
  await sidebar(page).getByRole('link', { name: 'Products', exact: true }).click()
  await expect(title(page, 'Products')).toBeVisible()
}

export async function openInvoices(page: Page): Promise<void> {
  await sidebar(page).getByRole('link', { name: 'Invoices', exact: true }).click()
  await expect(title(page, 'Invoices')).toBeVisible()
}

export function row(page: Page, text: string): Locator {
  return page.locator('[data-cy="dataTable"] tbody tr').filter({ hasText: text })
}

export async function listed(page: Page, text: string): Promise<boolean> {
  const empty = page.locator('[data-cy="dataTable"]').getByText('No records found', { exact: true })
  await expect(row(page, text).first().or(empty)).toBeVisible()
  return await row(page, text).first().isVisible()
}
