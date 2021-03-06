
# Author: tim
###############################################################################

#' the basic Sprague age-splitting method
#' 
#' @description This method is based on the first stage of the Sprague R 
#' script prepared by Thomas Buettner and Patrick Gerland, itself based on the description
#' in Siegel and Swanson, 2004, p. 727.
#' 
#' @param popmat a numeric matrix of population counts in 5-year age groups, with integer-labeled 
#' margins (age in rows and year in columns).
#' @details Ages should refer to lower age bounds, ending in the open age group in the last row (not a closed terminal age). 
#' Dimension labelling is necessary. There must be at least six age groups (including the open group). One year of data will 
#' work as well, as long as it's given as a single-column matrix.
#' 
#' @return an age-period matrix od split population counts with the same number of 
#' columns as \code{popmat}, and single ages in rows.
#' 
#' @references 
#' \insertRef{sprague1880explanation}{DemoTools}
#' \insertRef{shryock1973methods}{DemoTools}
#' \insertRef{siegel2004methods}{DemoTools}
#' @export
#' 
#' @examples 
#' p5 <- structure(c(54170, 44775, 42142, 38464, 34406, 30386, 26933, 
#' 				23481, 20602, 16489, 14248, 9928, 8490, 4801, 3599, 2048, 941, 
#' 				326, 80, 17, 0, 57424, 44475, 41752, 39628, 34757, 30605, 27183, 
#' 				23792, 20724, 17056, 14059, 10585, 8103, 5306, 3367, 2040, 963, 
#' 				315, 80, 16, 1, 60272, 44780, 41804, 40229, 35155, 30978, 27456, 
#' 				24097, 20873, 17546, 13990, 11146, 7841, 5738, 3184, 2062, 961, 
#' 				311, 80, 15, 1, 62727, 45681, 42101, 40474, 35599, 31439, 27758, 
#' 				24396, 21055, 17958, 14046, 11589, 7731, 6060, 3086, 2083, 949, 
#' 				312, 79, 14, 1, 64816, 47137, 42508, 40532, 36083, 31940, 28092, 
#' 				24693, 21274, 18299, 14223, 11906, 7785, 6255, 3090, 2084, 938, 
#' 				316, 80, 14, 2), 
#' 		.Dim = c(21L, 5L), 
#' 		.Dimnames = list(seq(0,100,by=5), 1950:1954))
#' head(p5) # this is the entire matrix
#' p1 <- sprague(p5)
#' head(p1); tail(p1)
#' colSums(p1) - colSums(p5) 
#' 
#' # another case, starting with single ages
#' # note \sprague() does not group ages. You need to do it 
#' # first.
#' Value <- c(9544406,7471790,11590109,11881844,11872503,12968350,11993151,10033918,
#' 		14312222,8111523,15311047,6861510,13305117,7454575,9015381,10325432,
#' 		9055588,5519173,12546779,4784102,13365429,4630254,9595545,4727963,
#' 		5195032,15061479,5467392,4011539,8033850,1972327,17396266,1647397,
#' 		6539557,2233521,2101024,16768198,3211834,1923169,4472854,
#' 		1182245,15874081,1017752,3673865,1247304,1029243,12619050,1499847,
#' 		1250321,2862148,723195,12396632,733501,2186678,777379,810700,
#' 		7298270,1116032,650402,1465209,411834,9478824,429296,1190060,
#' 		446290,362767,4998209,388753,334629,593906,178133,
#' 		4560342,179460,481230,159087,155831,1606147,166763,93569,182238,
#' 		53567,1715697,127486,150782,52332,48664,456387,46978,34448,
#' 		44015,19172,329149,48004,28574,9200,7003,75195,13140,5889,
#' 		18915,21221,72373)
#' Age         <- 0:100
#' # group ages
#' Val5        <- groupAges(Value, Age)
#' # name the vector (or dims of matrix if you end up
#' # producing a matrix)
#' names(Val5) <- Age[Age %% 5 == 0]
#' # notice how this particular case produces a negative value in the last age
#' # before OAG:
#' (pops <- sprague(Val5))
#' # this replaces ages 90+, guaranteed no negatives.
#' spragueCloseout(Val5, pops = pops)
#' # Note: there are no kludges built into sprague() to handle such cases.
#' # these ought to be handled by wrappers as appropriate.

sprague <- function(popmat){
	popmat            <- as.matrix(popmat)
	scm               <- spragueExpand(popmat)
	
	pop1              <- scm %*% popmat
	
	rg                <- range(as.integer(rownames(popmat)))
	dimnames(pop1)    <- list(rg[1]:rg[2], colnames(popmat))
	pop1
}

#' create the Sprague coefficient matrix 
#' 
#' @description The resulting coefficient matrix is based on the number of rows in \code{popmat}
#' where we assume that each row of data is a 5-year age group. The final row may be an open 
#' or closed age group, as indicated by the \code{OAG} argument.
#' 
#' @param popmat numeric matrix of age-period population counts in 5-year age groups
#' @param OAG logical (default \code{TRUE}. Is the final age group open?
#' 
#' @details The \code{popmat} matrix is really just a placeholder in this case. This function is 
#' a utility called by the Sprague family of functions, where it is most convenient to just pass
#' in the same matrix being used in those calcs to determine the layout of the coefficient matrix.
#' 
#' @export
#' 
#' @references 
#' \insertRef{sprague1880explanation}{DemoTools}
#' \insertRef{shryock1973methods}{DemoTools}
#' \insertRef{siegel2004methods}{DemoTools}
#' @examples
#' p5 <- structure(c(54170, 44775, 42142, 38464, 34406, 30386, 26933, 
#' 				23481, 20602, 16489, 14248, 9928, 8490, 4801, 3599, 2048, 941, 
#' 				326, 80, 17, 0, 57424, 44475, 41752, 39628, 34757, 30605, 27183, 
#' 				23792, 20724, 17056, 14059, 10585, 8103, 5306, 3367, 2040, 963, 
#' 				315, 80, 16, 1, 60272, 44780, 41804, 40229, 35155, 30978, 27456, 
#' 				24097, 20873, 17546, 13990, 11146, 7841, 5738, 3184, 2062, 961, 
#' 				311, 80, 15, 1, 62727, 45681, 42101, 40474, 35599, 31439, 27758, 
#' 				24396, 21055, 17958, 14046, 11589, 7731, 6060, 3086, 2083, 949, 
#' 				312, 79, 14, 1, 64816, 47137, 42508, 40532, 36083, 31940, 28092, 
#' 				24693, 21274, 18299, 14223, 11906, 7785, 6255, 3090, 2084, 938, 
#' 				316, 80, 14, 2), 
#' 		.Dim = c(21L, 5L), 
#' 		.Dimnames = list(seq(0,100,by=5), 1950:1954))
#' coefsOA     <- spragueExpand(p5, TRUE)
#' coefsclosed <- spragueExpand(p5, FALSE)
#' dim(coefsOA)
#' dim(coefsclosed)
spragueExpand <- function(popmat, OAG = TRUE){
	popmat <- as.matrix(popmat)
	
	# figure out ages and years
	Age5   <- as.integer(rownames(popmat))
	Age1   <- min(Age5):max(Age5)
	yrs    <- as.integer(colnames(popmat))
	
	# nr 5-year age groups
	m      <- nrow(popmat)
	# nr rows in coef mat.
	n      <- m * 5 - ifelse(OAG, 4, 0)
	# number of middle blocks
	MP     <- m - ifelse(OAG, 5, 4) 
	
	# get the split coefficients
	# block for ages 0-9
	g1g2 <- matrix(c(
					0.3616, -0.2768,  0.1488, -0.0336,  0.0000, 
					0.2640, -0.0960,  0.0400, -0.0080,  0.0000, 
					0.1840,  0.0400, -0.0320,  0.0080,  0.0000, 
					0.1200,  0.1360, -0.0720,  0.0160,  0.0000, 
					0.0704,  0.1968, -0.0848,  0.0176,  0.0000, 
					0.0336,  0.2272, -0.0752,  0.0144,  0.0000, 
					0.0080,  0.2320, -0.0480,  0.0080,  0.0000, 
					-0.0080,  0.2160, -0.0080,  0.0000,  0.0000, 
					-0.0160,  0.1840,  0.0400, -0.0080,  0.0000, 
					-0.0176,  0.1408,  0.0912, -0.0144,  0.0000), 
			nrow = 10, ncol = 5, byrow = TRUE)
	# block for middle ages
	
	
	g3 <- matrix(c(-0.0128,   0.0848,  0.1504,   -0.0240,  0.0016, 
					-0.0016,   0.0144,  0.2224,   -0.0416,  0.0064, 
					0.0064,  -0.0336,  0.2544,   -0.0336,  0.0064, 
					0.0064,  -0.0416,  0.2224,    0.0144, -0.0016, 
					0.0016,  -0.0240,  0.1504,    0.0848, -0.0128),
			5, 5, byrow = TRUE) 
	
	# block prior to closeout
	g4g5 <- matrix(c(0.0000, -0.0144,  0.0912,  0.1408, -0.0176, 
					0.0000, -0.0080,  0.0400,  0.1840, -0.0160, 
					0.0000,  0.0000, -0.0080,  0.2160, -0.0080, 
					0.0000,  0.0080, -0.0480,  0.2320,  0.0080, 
					0.0000,  0.0144, -0.0752,  0.2272,  0.0336, 
					0.0000,  0.0176, -0.0848,  0.1968,  0.0704, 
					0.0000,  0.0160, -0.0720,  0.1360,  0.1200, 
					0.0000,  0.0080, -0.0320,  0.0400,  0.1840, 
					0.0000, -0.0080,  0.0400, -0.0960,  0.2640, 
					0.0000, -0.0336,  0.1488, -0.2768,  0.3616), 
			nrow = 10, ncol = 5, byrow = TRUE)
	
	
	
	## create a Sprague coefficient matrix for 5-year age groups
	bm               <- matrix(0, nrow = n, ncol =  m)
	## insert upper left block
	bm[1:10, 1:5]    <- g1g2
	
	# determine positions of middle blocks
	rowpos           <- matrix(11:((MP * 5) + 10), ncol = 5, byrow = TRUE)
	colpos           <- row(rowpos) + col(rowpos) - 1
	for (i in (1:MP)) {
		# calculate the slices and add middle panels accordingly
		bm[rowpos[i, ], colpos[i, ]] <- g3
	}
	
	## insert last two panels
	
	fr                <- nrow(bm) - ifelse(OAG,10,9)
	lr                <- fr + 9
	fc                <- ncol(bm) - ifelse(OAG, 5, 4)
	lc                <- fc + 4
	bm[fr:lr,fc:lc]   <- g4g5
	
	if (OAG){
		# preserve open ended age group
		bm[nrow(bm), ncol(bm)]    <- 1
	}
	
	bm
}


#' create the Grabill coefficient matrix 
#' 
#' @description The resulting coefficient matrix is based on the number of rows in \code{popmat}
#' where we assume that each row of data is a 5-year age group and the final row is an open age group
#' to be preserved as such.
#' 
#' @param popmat numeric matrix of age-period population counts in 5-year age groups
#' 
#' @details The \code{popmat} matrix is really just a placeholder in this case. This function is 
#' a utility called by the Grabill family of functions, where it is most convenient to just pass
#' in the same matrix being used in those calcs to determine the layout of the coefficient matrix.
#' Note that these coefficients do not constrain population counts to their year totals. This function 
#' is called by \code{grabill()}, which ensures matching marginals by 1) blending boundary ages 
#' into the Sprague estimated population, and 2) a second constraint on the middle age groups to enforce
#' matching sums.
#' 
#' @references
#' \insertRef{shryock1973methods}{DemoTools}
#' 
#' @export

grabillExpand <- function(popmat){
	popmat            <- as.matrix(popmat)

	# nr 5-year age groups
	m                 <- nrow(popmat)
	# nr closed single ages
	m1                <- m * 5 - 5 
	# number of middle blocks
	MP                <- m - 5 
	
	## create a Grabill coefficient matrix for 5-year age groups
	scmg              <- matrix(0, nrow = m1 + 1, ncol =  m)
	
	## insert last two panels
	fr                <- (m - 3) * 5 + 1
	lr                <- (m - 1) * 5
	fc                <- MP 
	lc                <- MP + 4 
	
	# preserve open age group
	scmg[m1 + 1, m]   <- 1
	
	# primary grabill coef block
	g3g              <- matrix(
			             c(
					       0.0111,	0.0816,	 0.0826,	0.0256,	-0.0009,
					       0.0049,	0.0673,	 0.0903,	0.0377,	-0.0002,
					       0.0015,	0.0519,	 0.0932,	0.0519,	 0.0015,
					      -0.0002,	0.0377,	 0.0903,	0.0673,	 0.0049,
					      -0.0009,	0.0256,	 0.0826,	0.0816,	 0.0111),
			             5, 5, byrow = TRUE)
	# ----------------------------------------------------------
	# Note: for the boundary ages we keep shuffling in g3g, the same grabill
	# coefs. The columns on the boundaries will NOT sum to 1. These coefs are
	# used just for the firs pass, then results blend into the Sprague boundary
	# estimates.
	# ----------------------------------------------------------
	# the young age coefficients
	g1g2g              <- matrix(0,nrow=10,ncol=5)
	g1g2g[1:5, 1:3]    <- g3g[,3:5]
	g1g2g[6:10, 1:4]   <- g3g[,2:5]
	# the old age coefficients
	g4g5g              <- matrix(0,nrow=10,ncol=5)
	g4g5g[1:5, 2:5]    <- g3g[,1:4]
	g4g5g[6:10, 3:5]   <- g3g[,1:3]
	
	scmg[1:10, 1:5]    <- g1g2g
	scmg[fr:lr,fc:lc]  <- g4g5g
	
	# determine positions of middle blocks
	rowpos             <- matrix(11:((MP*5) + 10), ncol = 5, byrow = TRUE)
	colpos             <- row(rowpos) + col(rowpos) - 1
	for (i in (1:MP)) {
		# calculate the slices and add middle panels accordingly
		scmg[rowpos[i,], colpos[i, ]] <- g3g
	}
	# return coefficient matrix
	scmg
}

#' the basic Grabill age-splitting method
#' 
#' @description This method uses Grabill's aggressive redistribution of middle ages and blends into
#' Sprague estimated single-age population counts for the first and final ten ages. Open age groups
#' are preserved, as are annual totals.
#' 
#' @param popmat a numeric matrix of population counts in 5-year age groups, with integer-labeled 
#' margins (age in rows and year in columns).
#' @details Ages should refer to lower age bounds, ending in the open age group in the last row (not a closed terminal age). 
#' Dimension labelling is necessary. There must be at least six age groups (including the open group). One year of data will 
#' work as well, as long as it's given as a single-column matrix.
#' 
#' @return an age-period matrix od split population counts with the same number of 
#' columns as \code{popmat}, and single ages in rows.
#' 
#' @references 
#' \insertRef{shryock1973methods}{DemoTools}
#' 
#' @export
#' 
#' @examples 
#' p5 <- structure(c(54170.08, 44774.6, 42141.587, 38463.515, 34405.607, 
#' 162369.816, 57424.3568738, 44475.4981681, 41751.7574114, 39628.4338929, 
#' 34756.9473002, 164194.0485702, 60272.2061248, 44780.1982856, 
#' 41803.6541424, 40229.0292664, 35154.7682192, 166275.9022992, 
#' 62726.896388, 45681.1355532, 42100.72506, 40473.8600572, 35598.545404, 
#' 168556.5331816, 64815.5458002, 47136.5341033, 42508.3026466, 
#' 40532.3096745, 36082.7490698, 170990.473735, 66579.122, 49070.407, 
#' 42953.604, 40534.586, 36596.844, 173545.633), .Dim = c(6L, 6L
#' ), .Dimnames = list(seq(0,25,5), 1950:1955))
#' head(p5) # this is the entire matrix
#' p1 <- grabill(p5)
#' head(p1); tail(p1)
#' colSums(p1) - colSums(p5) 
#' p1 - sprague(p5)

grabill <- function(popmat){
	popmat            <- as.matrix(popmat)
	
	# get coefficient matrices for Sprague and Grabill
	scmg              <- grabillExpand(popmat)
	scm               <- spragueExpand(popmat)
	
	# split pop counts
	pops              <- scm %*% popmat
	popg              <- scmg %*% popmat
	
	# ---------------------------------------------
	# now we graft the two estimates in together,
	# preserving the middle part for grabill, and blending
	# aggressively into the young and closeout parts of Sprague
	# weights for grafting in grabill
	m                 <- nrow(pops)
	lr                <- m - 1
	fr                <- lr - 9
	
	# these weights do much better than linear weights.
	w10               <- exp(row(pops[1:10, , drop = FALSE]) ) / exp(10.1)
	
	# blend together young ages
	popg[1:10, ]      <- w10 * popg[1:10, ] + (1 - w10) * pops[1:10, ]
	
	# blend together old ages
	popg[fr:lr, ]     <- w10[10:1, ] * popg[fr:lr, ] + (1 - w10[10:1, ]) * pops[fr:lr, ]
	
	# ---------------------------------------------
	# now we take care of the marginal constraint problem
	# make weighting matrix 
	wr                <- pops * 0 + 1
	wr[1:10, ]        <- w10
	wr[fr:lr, ]       <- w10[10:1, ]
	wr[nrow(wr), ]    <- 0
	
	# weighted marginal sums. The difference we need to redistribute
	redist            <- colSums(pops) - colSums(popg)
	
	middle.part       <- popg * wr

	# the difference to redistribute
	add.in            <- t(t(prop.table(middle.part,2)) * redist)
	popg              <- popg + add.in
	# ---------------------------------------------
	# label dims and return
	rg                <- range(as.integer(rownames(popmat)))
	dimnames(popg)    <- list(rg[1]:rg[2], colnames(popmat))
	
	popg
}


#' split age groups using a monotonic spline
#' @description Take the cumulative sum of \code{Value} and then run a monotonic spline through it. The first 
#' differences split back single-age estimates of \code{Value}. Optionally keep the open age group untouched. 
#' 
#' @details We use the \code{"monoH.FC"} method of \code{stats::splinefun()} to fit the spline because 1)
#' it passes exactly through the points, 2) it is monotonic and therefore guarantees positive counts, and 3) 
#' it seems to be a bit less wiggly (lower average first differences of split counts) than a pchip tends to do, 
#' at least in the tested data.
#' 
#' @param Value numeric vector of counts in age groups
#' @param Age5 integer vector of lower bound of age groups
#' @param keep.OAG logical (default \code{FALSE}). Would we like to re-impute the last 
#' element of \code{Value} as the open age group?
#' @return numeric vector of single age counts 
#' @importFrom stats splinefun
#' @references 
#' \insertRef{fritsch1980monotone}{}
#' @export
#' @examples
#' Value <- structure(c(88623, 90842, 93439, 96325, 99281, 102051, 104351, 
#'				 106555, 109170, 112188, 113582, 112614, 108904, 102622, 95867, 
#'				 80874, 60196, 37523, 17927, 5642, 1110), .Names = c("0", "5", 
#'				 "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60", 
#'				 "65", "70", "75", "80", "85", "90", "95", "100"))
#'
#' splitMono(Value)
#' splitMono(Value, keep.OAG = TRUE)

splitMono <- function(Value, Age5 = seq(0, length(Value)*5-5, 5), keep.OAG = FALSE){
	AgePred    <- min(Age5):(max(Age5) + 1)
	y          <- c(0, cumsum(Value))
	x          <- c(0, Age5 + 5)
	y1         <- splinefun(y ~ x, method = "monoH.FC")(AgePred)
	single.out <- diff(y1)
	if (keep.OAG){
		single.out[length(single.out)] <- Value[length(Value)]
	}
	single.out
}

#' blend the Sprague upper boundary age estimates into monotonic spline estimates
#' 
#' @description A simple monotonic spline on the cumulative sum of population counts
#' may return more convincing single age count estimates than the Sprague splitting method.
#' This function blends the Sprague estimates starting at \code{pivotAge}.
#' 
#' @param popmat a numeric matrix of population counts in 5-year age groups, with integer-labeled 
#' margins (age in rows and year in columns).
#' @param pops optional numeric matrix of single age population counts derived from \code{popmat}.
#' @param pivotAge integer (default 90). Age at which to switch to spline-based estimates.
#' 
#' @return numeric matrix of age by year estimates of single-age counts.
#' 
#' @details The \code{pivotAge} must be at least 10 years below the maximum age detected from 
#' \code{rownames(popmat)}, but not lower than 80. In the exact \code{pivotAge}, we may either take
#' the Sprague estimates or the spline estimates, depending on which is larger, then the single-age estimates
#' for this 5-year age group are rescaled to sum to the original total in \code{popmat}. Higher ages are taken from
#' the spline-based age splits. The spline results are derive from the \code{"monoH.FC"} method of \code{splinefun()} 
#' on the cumulative sum of the original age grouped data. One could use this function to perform the same
#' closeout to Grabill estimates, if these are given via the \code{pops} argument. See examples. Note
#' that the Grabill split method mixed with this closeout will not necessarily preserve the annual totals,
#' and this function performs to rescaling. The open age group is preserved (and must be included in \code{popmat}).
#' 
#' @export 
#' 
#' @examples
#'  popmat <- structure(c(54170, 44775, 42142, 38464, 34406, 30386, 26933, 
#' 23481, 20602, 16489, 14248, 9928, 8490, 4801, 3599, 2048, 941, 
#' 326, 80, 17, 0, 57424, 44475, 41752, 39628, 34757, 30605, 27183, 
#' 23792, 20724, 17056, 14059, 10585, 8103, 5306, 3367, 2040, 963, 
#' 315, 80, 16, 1, 60272, 44780, 41804, 40229, 35155, 30978, 27456, 
#' 24097, 20873, 17546, 13990, 11146, 7841, 5738, 3184, 2062, 961, 
#' 311, 80, 15, 1, 62727, 45681, 42101, 40474, 35599, 31439, 27758, 
#' 24396, 21055, 17958, 14046, 11589, 7731, 6060, 3086, 2083, 949, 
#' 312, 79, 14, 1, 64816, 47137, 42508, 40532, 36083, 31940, 28092, 
#' 24693, 21274, 18299, 14223, 11906, 7785, 6255, 3090, 2084, 938, 
#' 316, 80, 14, 2), .Dim = c(21L, 5L), .Dimnames = list(c("0", "5", 
#' "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60", 
#' "65", "70", "75", "80", "85", "90", "95", "100"), c("1950", "1951", 
#' "1952", "1953", "1954")))
#' 
#' closed.out <- spragueCloseout(popmat)
#' colSums(closed.out) - colSums(popmat)
#' spragueCloseout(popmat, pivotAge = 85)
#' # giving a different single-age split to close out this way:
#' popg <- grabill(popmat)
#' grabill.closed.out <- spragueCloseout(popmat, popg)
#' # totals not necessarily preserved if mixed w Grabill
#' # I wouldn't recommend a rescale of the total, since the 
#' # only part we mess with here is the old age section. Ergo,
#' # one may wish to instead rescale results colSums() of 
#' # popg at age pivotAge and higher.
#' colSums(grabill.closed.out) - colSums(popmat)
#' # also works on an age-labelled vector of data
#' popvec <- popmat[,1]
#' closed.vec <- spragueCloseout(popvec)
#' # let's compare this one with sprague()
#' simple.vec <- sprague(popvec)
#' # and with a simple monotonic spline
#' mono.vec <- splitMono(popvec)
#' \dontrun{
#' plot(85:100,simple.vec[86:101], type = 'l', main = "In this case sprague() is the smoothest")
#' lines(85:100,closed.vec[86:101], col = "red", lwd = 2)
#' lines(85:100,mono.vec[86:101], col = "blue", lty = 2)
#' legend("topright",lty=c(1,2,2), col = c("black","red","blue"),lwd = c(1,2,1),
#' 		legend = c("sprague()","spragueCloseout()", "splitMono()"))
#' }
spragueCloseout <- function(popmat, pops, pivotAge = 90){
	popmat <- as.matrix(popmat)
	if (missing(pops)){
		pops    <- sprague(popmat)
	}
	# get the spline population split
	popmono <- apply(popmat, 2, splitMono, keep.OAG = TRUE)
	
	# some age pars
	Age5    <- as.integer(rownames(popmat))
	Age1    <- min(Age5):max(Age5)
	
	# some checks on pivotAge...
	if (!(max(Age1) - 10) >= pivotAge){
		pivotAge <- max(Age1) - 10
		if (pivotAge < 80){
			warning("pivotAge wasn't in rownames(popmat), moved it to 3rd 
from bottom row of popmat, but appears to be < 80
so returning sprague() output as-is, no extra closeout performed.")
            return(pops)
		}
		warning("pivotAge moved to ", pivotAge, ", continued.")
	}
	# -----------------------------
	# now begin the closeout blend.
	p.i              <- which(Age1 == pivotAge)
	## substitute Sprague interpolation if > pchip for better belnding of the two series
	pop.c            <- popmono[p.i:(p.i + 4), , drop = FALSE]
	ind              <- pops[p.i, ] > pop.c[1, ]
	pop.c[1, ind]    <- pops[p.i, ind] 

	## adjust back on initial pop 5x5 for age 90-94
	## proportional distribution
	pop.c[is.na(pop.c )] <- 0
	prop             <- prop.table(pop.c, margin = 2)
	pivot5           <- popmat[as.character(pivotAge), ]
    pop.c            <- t(t(prop) * pivot5)
	## append the remaining of the age groups (except last open age)
	## 95-99 onward
	m                <- nrow(pops)
	pop.c            <- rbind(pop.c, popmono[(p.i + 5):m, , drop = FALSE])
	## append Sprague interpolation before age 90
	pop.c            <- rbind(pops[1:(p.i - 1), , drop = FALSE], pop.c)
	
	## deal with negative values if applicable (but in principle should not be happening)
	pop.c[pop.c < 0] <- 0
	
	# label and return
	#dimnames(pop.c) <- list(Age1, colnames(popmat))
	rownames(pop.c) <- Age1
	colnames(pop.c) <- colnames(popmat)
	pop.c
}


#' an oscillatory average of Sprague age splits
#' @description Single ages can be grouped into 5-year age groups in 5 ways by staggering terminal digits.
#' This method is a bit smoother than the standard \code{sprague()} method, but not as smooth as \code{grabill()}.
#' 
#' @details This function works on a single vector of single-age counts, not on a matrix. Results are not
#' constrained to any particular age group, but are constrained to the total count.
#' The option to closeout using \code{spragueCloseout()} is recommended because it usually gives 
#' more plausible results and it avoids negative values. This is run separately on each Sprague split,
#' rather than on the aggregate results. 
#' 
#' @param Value numeric vector of single age counts
#' @param Age integer vector of single ages (lower bound)
#' @param OAG logical (default \code{TRUE}). Is the last value the open age group?
#' @param closeout logical (default \code{TRUE}). Shall we close out each sprague split with a monotonic spline fit?
#' 
#' @return numeric vector of Sprague-smoothed counts
#' @export
#' @examples
#' Value <- c(9544406,7471790,11590109,11881844,11872503,12968350,11993151,10033918,
#' 14312222,8111523,15311047,6861510,13305117,7454575,9015381,10325432,
#' 9055588,5519173,12546779,4784102,13365429,4630254,9595545,4727963,
#' 5195032,15061479,5467392,4011539,8033850,1972327,17396266,1647397,
#' 6539557,2233521,2101024,16768198,3211834,1923169,4472854,
#' 1182245,15874081,1017752,3673865,1247304,1029243,12619050,1499847,
#' 1250321,2862148,723195,12396632,733501,2186678,777379,810700,
#' 7298270,1116032,650402,1465209,411834,9478824,429296,1190060,
#' 446290,362767,4998209,388753,334629,593906,178133,
#' 4560342,179460,481230,159087,155831,1606147,166763,93569,182238,
#' 53567,1715697,127486,150782,52332,48664,456387,46978,34448,
#' 44015,19172,329149,48004,28574,9200,7003,75195,13140,5889,
#' 18915,21221,72373)
#' Age <- 0:100
#' names(Value) <- Age
#' #barplot(Value, main = "yup, these have heaping!")
#' # this is the basic case we compare with:
#' pop0    <- sprague(groupAges(Value,Age))
#' # note: this function needs single ages to work because
#' # ages are grouped into 5-year age groups in 5 different ways.
#' (pop1   <- spragueOscillate(Value, Age, closeout = FALSE))
#' # see the NaN value? That because there were some negatives produced by 
#' # sprague(). We can call spragueCloseout() inside spragueOscillate()
#' # to handle such cases:
#' (pop2   <- spragueOscillate(Value, Age, closeout = TRUE))
#' # what's smoother, spragueOscillate() or grabill()?
#' # note, same closeout problem, can be handled by spragueCloseout()
#' (pop3   <- grabill(groupAges(Value, Age)))
#' #pop4   <- spragueCloseout(groupAges(Value, Age), pops = pop3)
#' \dontrun{
#' plot(Age, Value)
#' lines(Age, pop0, col = "blue")
#' # slightly smoother (also shifted though)
#' lines(Age, pop1)
#' # only different at very high ages, small nrs
#' lines(Age, pop2, col = "red", lty = 2, lwd = 2) 
#' lines(Age, pop3, col = "magenta")
#' legend("topright", lty = c(1,1,2,1), lwd = c(1,1,2,1), col = c("blue","black","red","magenta"),
#' 		legend = c("sprague()",
#'                 "spragueOscillate(closeout = FALSE)", 
#' 				   "spragueOscillate(closeout = TRUE)",
#' 				   "grabill()"))
#' }

spragueOscillate <- function(Value, Age, OAG = TRUE, closeout = TRUE){
	
	N     <- length(Value)
	if (OAG){
		open   <- Value[N]
		OA     <- Age[N]
		Value  <- Value[-N]
		Age    <- Age[-N]
		N      <- N - 1
	} 
	TOT <- sum(Value)
# select which ages to keep:
	p1x1   <- matrix(nrow = length(Value), ncol = 5)
	rownames(p1x1) <- Age
	for (i in 0:4){
		# regroup ages
		Age.i.5             <- calcAgeN(Age, shiftdown = i)
		# only use age groups w 5 single ages represented
		keep.i              <- rep(rle(Age.i.5)$leng, rle(Age.i.5)$leng) == 5
		# cut vector down to those cases
		Age.i.5             <- Age.i.5[keep.i]
		# cut counts down to those cases
		Val.i               <- Value[keep.i]
		# group ages into said 5-year age groups
		Val.i.5             <- groupAges(Val.i, AgeN = Age.i.5)
		# make fake open age
		Val.i.5             <- c(Val.i.5, pi)
		names(Val.i.5)      <- c(unique(Age.i.5), max(Age.i.5) + 5)
		# get first run estimate
		pop.est             <- sprague(Val.i.5)
		if (closeout){
			pop.est <- spragueCloseout(Val.i.5, pop.est)
		}
		
		pop.est[pop.est < 0] <- NA
		pop.est             <- pop.est[-length(pop.est)]
		p1x1[keep.i, i + 1] <- pop.est
	}
	# take average per age
	p.out <- rowMeans(p1x1, na.rm = TRUE)
	# rescale to proper total
	p.out <- p.out * TOT / sum(p.out, na.rm = TRUE)
	# re-append the open age group if needed
	if (OAG){
		Age   <- c(Age, OA)
		p.out <- c(p.out, open)
		names(p.out) <- Age
	}
	
	pop.c
}


Value = c(`0` = 322450, `1` = 847314, `2` = 890815, `3` = 973324, `4` = 922761, 
          `5` = 1353923, `6` = 446856, `7` = 617082, `8` = 729849, `9` = 793670, 
          `10` = 839793, `11` = 765702, `12` = 898146, `13` = 834513, `14` = 662849, 
          `15` = 835059, `16` = 878426, `17` = 783401, `18` = 877720, `19` = 1005015, 
          `20` = 1049289, `21` = 758123, `22` = 838049, `23` = 761735, 
          `24` = 623166, `25` = 920335, `26` = 579951, `27` = 632815, `28` = 620611, 
          `29` = 402083, `30` = 891491, `31` = 336850, `32` = 517889, `33` = 384614, 
          `34` = 287516, `35` = 900013, `36` = 345989, `37` = 360808, `38` = 431534, 
          `39` = 273062, `40` = 817674, `41` = 244233, `42` = 444999, `43` = 347551, 
          `44` = 215034, `45` = 825759, `46` = 270679, `47` = 272653, `48` = 313531, 
          `49` = 195134, `50` = 605866, `51` = 176668, `52` = 311271, `53` = 228275, 
          `54` = 221397, `55` = 504827, `56` = 203723, `57` = 162895, `58` = 201118, 
          `59` = 141621, `60` = 369704, `61` = 126829, `62` = 170236, `63` = 132706, 
          `64` = 99812, `65` = 364710, `66` = 76709, `67` = 96552, `68` = 64537, 
          `69` = 38543, `70` = 234801, `71` = 36986, `72` = 55415, `73` = 45925, 
          `74` = 29362, `75` = 127797, `76` = 28914, `77` = 20376, `78` = 19258, 
          `79` = 10656, `80` = 70877, `81` = 9732, `82` = 12709, `83` = 9495, 
          `84` = 7199, `85` = 27178, `86` = 5804, `87` = 3769, `88` = 2598, 
          `89` = 1462, `90` = 9682, `91` = 1303, `92` = 1357, `93` = 1194, 
          `94` = 725, `95` = 2259, `96` = 443, `97` = 323, `98` = 329, 
          `99` = 1291)


Age = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 
        18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
        34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
        50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 
        66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 
        82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 
        98, 99)

graduate_grabill(Value, Age, OAG = TRUE)
