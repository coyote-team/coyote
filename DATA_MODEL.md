# Coyote Data Model

## User

Users are global, and belong to one or more organizations via "memberships". The have a name, email, and password.

## License

Licenses are global.

- Name: The friendly name of the license
- Description: Anything can go here but the full name of the license is a nice default, or a longer description of what the license means, etc.
- URI: The URI where this license can be found

## Organization

- Name: Name of the Organization
- Default License: This points to a License that should be used when no License is defined for a representation.

## Resource

Resources belong to Organizations and Resource Groups.

- Source URI (required): URI of the resource; typically points to an image file
- Name (optional): The name of the resource (this is not always known at creation time e.g. creating resources out of photos from a website). Sometimes, the caption of an image is provided as the name.
- Host URIs (optional): The list of URIs where resource found at source URI is used/present. Think of a webpage as the Host URI and the Source URI is the path to the .jpeg file. That file can be used elsewhere on the site, therefore Host URIs is an array.
- Canonical ID (optional): This may be used in API URIs or web URLs but only explicitly e.g. `resources/canonical/:canonical_id` which will always redirect to `/resources/coyote-id`.
- Priority flag: Boolean that represents resources that should be bubbled up when sorting. This is the default when doing any sorting e.g. Priority items are the default sort on the UI.
- Reosurce type: only valid option is "image". Reserved for future support of additional resource types.

## Resource Group

Resource Groups belong to an organization. They are used to organize resources into sets.

- Name: User-visible string
- Webhook URI (optional): the callback URI for changes to value and status
- Token (private, read-only): used to generate the JWT headers that webhook recipients can (and should) use to verify requests

## Metum

Meta belong to Organizations and are used to clarify the context of a representation, e.g. a resource can have a representation with metum "Alt" which would be appropriate to use as `alt` text on an `img` tag.

- Name: The visible name of the metum.
- Instructions: The text that appears on screen for authors when writing a representation with a given metum

## Representation

Representations belong to Organizations and resources.

- Content Type: Essentially the mime type for the content of the representation. Defaults to text/plain.
- Text (optional): text of the representation, assuming text/plain as the content-type. Required if content URI is blank.
- Content URI (optional): URI where the content of the representation can be found. Required if text is blank.
- Language: The two-letter language code of the Representation.
- Notes (optional): text to be shown when representation is viewed in Coyote
- Ordinality: defaults to 0. When multiple representations of the same metum are present, ordinality dictates precedence
- Status: The status of this representation in the description workflow. Can be one of "ready_to_review", "approved" or "not_approved".
- Author: user that authored this representation
- Metum: The metum for this representation.
