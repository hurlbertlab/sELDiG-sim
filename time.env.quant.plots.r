# Function for plotting 
repo_dir = 'C:/Documents and Settings/Hurlbert/species-energy-simulation'
sim_dir = 'C:SENCoutput'

sim.matrix = read.csv(paste(repo_dir,'/SENC_Master_Simulation_Matrix.csv',sep=''),header=T)

sim.df = data.frame(K.sims.trop = 3325:3334, K.sims.temp=3345:3354, D.sims.trop = 3445:3454, D.sims.temp=3455:3464, T.sims.trop=3365:3374, T.sims.temp=3385:3394)

for (i in 1:6) {
  stats.output.tmp = c()
  for (j in 1:10) {
    tmp = read.csv(paste(sim_dir,'/SENC_stats_sim',sim.df[j,i],'.csv',sep=''), header=T)
    stats.output.tmp = rbind(stats.output.tmp, tmp)
  }
  write.csv(stats.output.tmp, paste(sim_dir,'/SENC_Stats_',names(sim.df)[i],'.csv',sep=''), row.names=F)
}



min.num.data.pts = 10
min.num.spp.per.clade = 30
min.num.regions = 5
upper.quant = .9
lower.quant = .1

par(mfcol=c(2,3), mar = c(4,4,1,1), oma = c(2,1,1,1))
  
for (i in 1:3) {
  stats.output1 = read.csv(paste(sim_dir,'/SENC_Stats_',names(sim.df[2*i-1]),'.csv',sep=''), header=T)  
  stats.output2 = read.csv(paste(sim_dir,'/SENC_Stats_',names(sim.df[2*i]),'.csv',sep=''), header=T)
  x = subset(stats.output1, n.regions >= min.num.regions & clade.richness >= min.num.spp.per.clade)
  z = subset(stats.output2, n.regions >= min.num.regions & clade.richness >= min.num.spp.per.clade)

  plot(log10(x$clade.origin.time), x$r.env.rich, type="n",xlab="",ylab="r (Env-Richness)",ylim=c(-1,1))
  quantreg.triangle(log10(x$clade.origin.time), x$r.env.rich, upper.quant, lower.quant, col = rgb(.9,.1,.1,.1))
  
  #points(log10(z$clade.origin.time), z$r.env.rich, pch = 15, cex=.5, col='red')
  quantreg.triangle(log10(z$clade.origin.time), z$r.env.rich, upper.quant, lower.quant, col = rgb(.1,.1,.9,.1))
  
  plot(log10(x$clade.origin.time), x$r.time.rich,  type="n",xlab="",ylab="r (Time-Richness)",ylim=c(-1,1))
  quantreg.triangle(log10(x$clade.origin.time), x$r.time.rich, upper.quant, lower.quant, col = rgb(.9,.1,.1,.1))
  
  #points(log10(z$clade.origin.time), z$r.time.rich, pch = 15, cex=.5, col='red')
  quantreg.triangle(log10(z$clade.origin.time), z$r.time.rich, upper.quant, lower.quant, col = rgb(.1,.1,.9,.1))
  
}  
  
  y = subset(stats.output, n.regions >= min.num.regions & clade.richness >= min.num.spp.per.clade & reg.of.origin=='temperate')
  starting.clades = aggregate(y$clade.richness, by = list(y$sim), max)
  names(starting.clades) = c('sim','clade.richness')
  clade.origin = merge(starting.clades, y, by= c('sim','clade.richness'))
  
  plot(log10(y$clade.origin.time), y$r.env.rich, xlab="",ylab="r (Env-Richness)",ylim=c(-1,1),
       main = paste("Sim ",sim.params$sim.id[1],", ",K.text,"\norigin = ",
                    sim.params[1,3],", dist.freq = ", sim.params[1,'disturb_frequency'], sep=""))
  quantreg.triangle(log10(y$clade.origin.time), y$r.env.rich, upper.quant, lower.quant, col = rgb(.1,.1,.9,.1))
  
  
  if (length(x$r.time.rich[!is.na(x$r.time.rich)]) > min.num.data.pts) {
    plot(log10(x$clade.origin.time), x$r.time.rich, xlab = "",ylab="r (Time-Richness)",ylim=c(-1,1))
    rect(-1000,.5,t+50,1.1,col=rgb(.1,.1,.1,.1),lty=0)
    points(smooth.spline(log10(x$clade.origin.time[!is.na(x$r.time.rich)]),x$r.time.rich[!is.na(x$r.time.rich)],df=spline.df),type='l',col='red')
    points(log10(clade.origin$clade.origin.time), clade.origin$r.time.rich, col = 'skyblue', pch = 17, cex = 2)
  } else { 
    plot(1,1,xlab="",ylab = "r (Time-Richness)",type="n",xlim=c(0,t),ylim=c(-1,1))
  }
  mtext("Clade origin time",1,outer=T,line=1.2)
}
